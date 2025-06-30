require_relative "../../lib/cognito_service"

user_pool_id = ENV["COGNITO_USER_POOL_ID"]
region = ENV["COGNITO_REGION"]

credentials = if ENV["COGNITO_ACCESS_KEY_ID"].nil?
                  # Aws::Credentials.new()
                  raise "not implemented"
else
                  Aws::Credentials.new(ENV["COGNITO_ACCESS_KEY_ID"], ENV["COGNITO_SECRET_ACCESS_KEY"])
end

Rails.application.config.cognito = CognitoService.new(user_pool_id:, credentials:, region:)
