class UserRegistrationsController < ApplicationController
  skip_before_action :authenticate_user, only: [:register]
  skip_before_action :set_company_context, only: [:register]
  skip_after_action :verify_authorized, only: [:register]
  skip_after_action :verify_policy_scoped, only: [:register]

  def register
    subject = get_subject_from_auth_header(user_profile_params[:email])
    raise UnauthorizedError if subject.blank?

    # Find existing user profile or create a new one
    @user_profile = UserProfile.find_by(email: user_profile_params[:email])

    if @user_profile.nil?
      # Create new user profile if it doesn't exist
      @user_profile = UserProfile.new(user_profile_params)
      @user_profile.save!

      # Create user credential for new user
      @user_credential = UserCredential.new(
        user_profile: @user_profile,
        subject: subject
      )
      @user_credential.save!
    end

    # Create tenant first
    @tenant = Tenant.find_by(name: "Trackc")

    # Create Company
    @company = Company.new(
      name: company_params[:name],
      code: generate_company_code(company_params[:name]),
      company_type: company_params[:company_type],
      owned_by: @user_profile,
      tenant: @tenant
    )
    @company.save!
    @role = AccessRole.find_by(id: role_params[:id])
    # Create company member for the owner
    @company_member = CompanyMember.new(
      profile: @user_profile,
      company: @company,
      invited_at: Time.current,
      joined_at: 1.minute.from_now,
      access_role: @role
    )
    @company_member.save!

    render :register, status: :created
  rescue ActiveRecord::RecordInvalid => e
    @errors = []
    @errors.concat(@user_profile.errors.full_messages) if @user_profile&.errors&.any?
    @errors.concat(@company.errors.full_messages) if @company&.errors&.any?
    @errors.concat(@company_member.errors.full_messages) if @company_member&.errors&.any?
    @errors.concat(@tenant.errors.full_messages) if @tenant&.errors&.any?
    @errors.concat(@user_credential.errors.full_messages) if @user_credential&.errors&.any?
    @errors << e.message if @errors.empty?

    raise ValidationFailed.new(@errors)
  end

  private

  def get_subject_from_auth_header(email)
    Rails.application.config.cognito.get_sub_by_email(email)
  end

  def user_profile_params
    params.require(:user_profile).permit(
      :first_name,
      :last_name,
      :email
    )
  end

  def company_params
    params.require(:company).permit(
      :name,
      :company_type
    )
  end

  def role_params
    params.require(:role).permit(:id)
  end

  def generate_company_code(name)
    "#{name.parameterize.upcase}-#{SecureRandom.alphanumeric(6)}"
  end

  def generate_account_code(name)
    "ACC-#{name.parameterize.upcase}-#{SecureRandom.alphanumeric(6)}"
  end
end