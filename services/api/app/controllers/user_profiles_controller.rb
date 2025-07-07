class UserProfilesController < ApplicationController
  allow_unauthenticated_access only: [:create, :activate]

  def show
    @user = current_user
    @last_company_access = @user.company_members
                               .order(updated_at: :desc)
                               .includes(:company, :access_role)
                               .first

    @role = @last_company_access&.access_role
    @company = @last_company_access&.company

    render :show
  end

  def upsert
    subject = get_subject_from_auth_header(user_profile_params[:email])
    raise UnauthorizedError if subject.blank?

    # Find existing user profile or create a new one
    @user = UserProfile.find_by(email: user_profile_params[:email])

    if @user.nil?
      # Create new user profile if it doesn't exist
      @user = UserProfile.new(user_profile_params)
      @user.active = false if @user.super_admin?
      @user.save!

      # Create user credential for new user
      @user_credential = UserCredential.new(
        user_profile: @user,
        subject: subject
      )
      @user_credential.save!
    else
      # Update existing user
      @user.update!(user_profile_params)
    end

    render :show
  rescue ActiveRecord::RecordInvalid => e
    @errors = @user&.errors&.full_messages || [e.message]
    render :error, status: :unprocessable_entity
  end

  def update
    upsert
  end

  def create
    upsert
  end

  def activate
    @user = UserProfile.find(params[:id])

    if @user.update(active: true)
      render :show
    else
      @errors = @user.errors.full_messages
      render :error, status: :unprocessable_entity
    end
  end

  private

  def get_subject_from_auth_header(email)
    Rails.application.config.cognito.get_sub_by_email(email)
  end


  def user_profile_params
    params.require(:user_profile).permit(:first_name, :last_name, :phone_no, :email, :super_admin)
  end

end
