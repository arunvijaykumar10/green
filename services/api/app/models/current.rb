class Current < ActiveSupport::CurrentAttributes
  # User context
  attribute :user_profile
  
  # Company context
  attribute :company
  
  # Request context
  attribute :request_id
  attribute :user_agent
  attribute :ip_address
end