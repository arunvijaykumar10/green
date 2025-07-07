module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      Current.user_profile.present?
    end

    def require_authentication
      authenticate_user
    end

    def authenticate_user
      return if Current.user_profile

      # Try session-based auth first
      email = session[:email]
      if email
        Current.user_profile = UserProfile.find_by(email: email)
        return if Current.user_profile
      end

      # Try token-based auth if Authorization header present
      if request.headers['Authorization'].present?
        begin
          subject = parse_subject_from_auth_header
          email = Rails.application.config.cognito.get_email_from_sub(subject)
          Current.user_profile = UserProfile.find_by(email: email)
          return if Current.user_profile
        rescue => e
          Rails.logger.error "Token authentication failed: #{e.message}"
        end
      end

      request_authentication
    end

    def parse_subject_from_auth_header
      token = request.headers["Authorization"]&.split(" ")&.last
      raise "No token" if token.blank?

      decoded_token = Rails.application.config.cognito.decode_token(token)
      raise "Invalid token" if decoded_token.blank?

      decoded_token[0]["sub"]
    end

    def request_authentication
      render json: { status: "error", message: "Authentication required" }, status: :unauthorized
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def current_user
      Current.user_profile
    end

    def current_company
      Current.company
    end
end
