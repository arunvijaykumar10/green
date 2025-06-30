# frozen_string_literal: true

require "aws-sdk-cognitoidentityprovider"
require "jwt"

class CognitoService
  def initialize(user_pool_id:, region:, credentials:)
    @user_pool_id = user_pool_id
    @region = region
    @client = Aws::CognitoIdentityProvider::Client.new(credentials:, region:)
  end

  def invite_user(username, attributes, options = {})
    user_attributes = attributes.map { |name, value| Types::Field.new(name: name.to_s, value:) }
    payload = Types::UserCreate.new(
      user_attributes:,
      user_pool_id:,
      username:
    ).to_h
    client.admin_create_user(payload, options)
  end

  def get_sub_by_email(email)
    @client.admin_get_user({ user_pool_id:, username: email })
          .user_attributes.find { |attr| attr.name == "sub" }.value
  end

  def decode_token(token)
    JWT.decode(token, nil, true, { jwks: jwt_config, algorithms: [ "RS256" ] })
  end

  def get_email_from_sub(subject)
     res = @client.list_users({
      user_pool_id: ENV["COGNITO_USER_POOL_ID"],
      filter: "sub = \"#{subject}\""
    })

    user = res.users.first
    if user
      user.attributes.find { |attr| attr.name == "email" }&.value
    else
      Rails.logger.warn "No Cognito user found with sub=#{subject}"
      nil
    end
  end

  def jwt_config
    @_jwt_config ||= begin
                        aws_idp = Faraday.get("https://cognito-idp.#{region}.amazonaws.com/#{user_pool_id}/.well-known/jwks.json").body
                        JSON.parse(aws_idp, symbolize_names: true)
                      end
  end

  private

  attr_reader :client, :user_pool_id, :region
end
