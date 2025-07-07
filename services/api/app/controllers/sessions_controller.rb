class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render json: { status: "error", message: "Too many login attempts. Try again later." }, status: :too_many_requests }
  skip_before_action :set_company_context, only: [:create, :select_company_form, :set_company]
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def new
    render :new
  end

  def create
    user_profile = UserProfile.active.find_by(email: params[:email])
    if user_profile && authenticate_with_cognito(params[:email])
      session[:user_profile_id] = user_profile.id
      Current.user_profile = user_profile

      if user_profile.super_admin?
        handle_super_admin_login(user_profile)
      elsif user_profile.admin?
        handle_admin_login(user_profile)
      else
        handle_employee_login(user_profile)
      end
    else
      render_unauthorized("Invalid email or password.")
    end
  end

  def select_company_form
    @companies = accessible_companies_for(Current.user_profile)
    render :select_company
  end

  def set_company
    companies = accessible_companies_for(Current.user_profile)
    company = companies.find_by(id: params[:company_id])

    if company
      session[:current_company_id] = company.id
      Current.company = company
      log_company_access(Current.user_profile, company, "switch_company")

      @redirect_path = dashboard_path
      render :set_company
    else
      render_unprocessable("Invalid company selection or you do not have access.")
    end
  end

  def destroy
    log_company_access(Current.user_profile, Current.company, "logout") if Current.user_profile && Current.company
    session.clear
    Current.user_profile = nil
    Current.company = nil
    render :destroy
  end

  private

  def authenticate_with_cognito(email)
    return false if email.blank?

    begin
      # Check if user exists in Cognito by getting their sub
      sub = Rails.application.config.cognito.get_sub_by_email(email)
      sub.present?
    rescue => e
      Rails.logger.error "Cognito authentication failed: #{e.message}"
      false
    end
  end

  def dashboard_path
    "/dashboard"
  end

  def accessible_companies_for(user_profile)
    if user_profile.super_admin?
      Company.active
    else
      user_profile.companies.active
    end
  end

  def handle_super_admin_login(user_profile)
    @redirect_path = "/company_reviews"
    render :create
  end

  def handle_admin_login(user_profile)
    companies = user_profile.companies.active
    if companies.one?
      select_company_and_redirect(user_profile, companies.first)
    elsif companies.any?
      @redirect_path = select_company_path
      render :create
    else
      render_unauthorized("You are not assigned to any active companies.")
    end
  end

  def handle_employee_login(user_profile)
    company_member = CompanyMember.find_by(profile: user_profile)
    if company_member&.company&.active?
      select_company_and_redirect(user_profile, company_member.company)
    else
      render_unauthorized("You are not associated with any active company.")
    end
  end

  def select_company_and_redirect(user_profile, company)
    session[:current_company_id] = company.id
    Current.company = company
    log_company_access(user_profile, company, "login")
    @redirect_path = dashboard_path
    render :create
  end

  def render_unauthorized(message)
    @error_message = message
    render :error, status: :unauthorized
  end

  def render_unprocessable(message)
    @error_message = message
    render :error, status: :unprocessable_entity
  end
end
