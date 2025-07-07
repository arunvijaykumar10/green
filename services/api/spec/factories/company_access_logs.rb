FactoryBot.define do
  factory :company_access_log do
    association :user_profile
    association :company
    action_type { ["login", "switch_company", "view_dashboard", "logout"].sample }
  end
end
