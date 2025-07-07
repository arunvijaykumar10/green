# lib/tasks/mock_users.rake

namespace :cognito do
  desc "Add 5 mock verified users to Cognito"
  task add_mock_users: :environment do
    require "securerandom"
    require "aws-sdk-cognitoidentityprovider"

    client = Aws::CognitoIdentityProvider::Client.new(
      region: ENV["COGNITO_REGION"],
      access_key_id: ENV["COGNITO_ACCESS_KEY_ID"],
      secret_access_key: ENV["COGNITO_SECRET_ACCESS_KEY"]
    )

    mock_emails = [
      "arunkumar@drylogics.com",
    ]

    password = "Arun@123  " 

    mock_emails.each do |email|
      begin
        # Create the user with email_verified = true and no email notification
        client.admin_create_user({
          user_pool_id: ENV["COGNITO_USER_POOL_ID"],
          username: email,
          temporary_password: password,
          user_attributes: [
            { name: "email", value: email },
            { name: "email_verified", value: "true" }
          ],
          message_action: "SUPPRESS"
        })

        puts "✅ Created user: #{email}"

        # Set a permanent password (simulating first login complete)
        client.admin_set_user_password({
          user_pool_id: ENV["COGNITO_USER_POOL_ID"],
          username: email,
          password: password,
          permanent: true
        })

        puts "🔒 Password set for: #{email}"

      rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
        puts "❌ Failed for #{email}: #{e.message}"
      end
    end
  end

  desc "Delete a Cognito user by exact email"
  task delete_user: :environment do
    require "aws-sdk-cognitoidentityprovider"

    email = ENV['EMAIL']
    user_pool_id = ENV['COGNITO_USER_POOL_ID']
    region = ENV['COGNITO_REGION']
    access_key = ENV['COGNITO_ACCESS_KEY_ID']
    secret_key = ENV['COGNITO_SECRET_ACCESS_KEY']

    if email.blank? || user_pool_id.blank? || region.blank?
      puts "❌ Please provide EMAIL, COGNITO_USER_POOL_ID, and COGNITO_REGION"
      puts "Example:"
      puts "rake cognito:delete_user EMAIL='mockuser1@example.com' COGNITO_USER_POOL_ID='your-pool-id' COGNITO_REGION='your-region'"
      exit
    end

    client = Aws::CognitoIdentityProvider::Client.new(
      region: region,
      access_key_id: access_key,
      secret_access_key: secret_key
    )

    begin
      resp = client.list_users({
        user_pool_id: user_pool_id,
        filter: "email = \"#{email}\""
      })

      if resp.users.empty?
        puts "⚠️ No user found with email: #{email}"
      else
        resp.users.each do |user|
          client.admin_delete_user({
            user_pool_id: user_pool_id,
            username: user.username
          })
          puts "✅ Deleted user: #{user.username} (#{email})"
        end
      end
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      puts "❌ Failed to delete #{email}: #{e.message}"
    end
  end
end
