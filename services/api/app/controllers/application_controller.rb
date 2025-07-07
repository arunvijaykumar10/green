class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  skip_before_action :verify_authenticity_token
  around_action :wrap_in_transaction, except: [ :index, :show ]

  before_action :set_company_context, unless: :skip_company_context_for_super_admin?
  before_action :force_json
  helper_method :current_user, :current_company

  rescue_from UnauthorizedError, with: :handle_unauthorized_error
  # rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ValidationFailed, with: :handle_validation_failed
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Pundit-specific callbacks
  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  protected

  def parse_subject_from_auth_header
    token = request.headers["Authorization"]&.split(" ")&.last
    raise UnauthorizedError if token.blank?

    decoded_token = Rails.application.config.cognito.decode_token(token)
    raise UnauthorizedError if decoded_token.blank?

    decoded_token[0]["sub"]
  end

  # Pundit helper: provides Current.user_profile to views.
  def current_user
    Current.user_profile
  end

  # Pundit helper: provides Current.company to views.
  def current_company
    Current.company
  end

  private

  def set_current_attributes
    Current.company = current_company
    Current.user_profile = current_user
    Current.request_id = request.__id__
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  def handle_unauthorized_error
    head :unauthorized
  end

  def record_invalid(ex)
    render json: {
      status: "error",
      message: "Operation failed",
      errors: [ ex.message ]
    }, status: :unprocessable_entity
  end

  def handle_validation_failed(ex)
    render json: {
      status: "error",
      message: "Operation failed",
      errors: ex.errors
    }, status: :unprocessable_entity
  end



  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end

  def force_json
    request.format = :json
  end

  def user_not_authorized
    render json: {
      status: "error",
      message: "You are not authorized to perform this action"
    }, status: :forbidden
  end

  # Pundit's default method to get the user object for policy decisions.
  # We alias it to our `Current.user_profile`.
  def pundit_user
    Current.user_profile
  end

  def set_company_context
    return if skip_company_context? # Skip for super admins on certain controllers
    return unless Current.user_profile # Only proceed if a user is logged in
    return if Current.company # If company is already set (e.g., by select_company_form during initial load)

    company_id_from_session = session[:current_company_id]

    if company_id_from_session.present?
      # Find the company and ensure the current user has an active membership to it
      company = Current.user_profile.companies.active.find_by(id: company_id_from_session)
      if company
        Current.company = company # Set the global current company for the request
      else
        # Company ID in session is invalid, or user doesn't have access, or company is inactive/discarded
        clear_company_session_and_redirect("Invalid company selected or you no longer have access to it.", select_company_path)
      end
    else
      # User is logged in but no company is selected in session
      handle_no_company_selected
    end
  end

  # Handles scenarios where a user is logged in but no company context is set.
  def handle_no_company_selected
    user_companies = Current.user_profile.companies.active # Get active companies user belongs to

    if user_companies.one?
      # If user has access to only one active company, automatically select it.
      company = user_companies.first
      session[:current_company_id] = company.id
      Current.company = company
      log_company_access(Current.user_profile, company, "login") # Log initial login access
    elsif user_companies.any?
      # Redirect to company selection page if multiple companies exist and not already on the selection page
      # This prevents an infinite redirect loop if the user is on /select_company
      unless ["sessions"].include?(params[:controller]) && ["select_company_form", "set_company"].include?(params[:action])
        redirect_to select_company_path, alert: "Please select a company to proceed."
      end
    else
      # User has no associated active companies at all (edge case)
      clear_company_session_and_redirect("You are not associated with any active companies. Please contact support.", login_path)
    end
  end

  # Clears the company context from session and Current, then redirects.
  def clear_company_session_and_redirect(message, redirect_path)
    session.delete(:current_company_id)
    Current.company = nil # Clear the global current company
    redirect_to redirect_path, alert: message
  end

  # Logs company access events.
  def log_company_access(user_profile, company, action_type)
    return unless user_profile && company # Ensure context exists before logging
    CompanyAccessLog.create(user_profile: user_profile, company: company, action_type: action_type)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to log company access for UserProfile #{user_profile.id}, Company #{company.id}: #{e.message}"
  end

  # Provides additional context to Pundit policies.
  # This allows policies to access both the user and the currently selected company.
  def pundit_context
    { user_profile: Current.user_profile, company: Current.company }
  end

  def skip_pundit?
    params[:controller] =~ /(^(rails_)?admin)|(^pages$)/ || 
    %w[sessions user_registrations access_roles user_profiles].include?(params[:controller])
  end

  def skip_company_context?
    %w[company_reviews companies].include?(params[:controller]) && Current.user_profile&.super_admin?
  end

  def skip_company_context_for_super_admin?
    Current.user_profile&.super_admin?
  end
end
