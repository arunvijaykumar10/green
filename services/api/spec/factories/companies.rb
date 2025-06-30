FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    code { "#{name.parameterize.upcase}-#{SecureRandom.alphanumeric(6)}" }
    company_type { %w[business individual].sample }
    
    association :owned_by, factory: :user_profile
    association :tenant
    
    trait :approved do
      approved { true }
      approved_at { Time.current }
      association :approved_by, factory: :user_profile
    end
    
    trait :not_approved do
      approved { false }
      approved_at { nil }
      approved_by { nil }
    end
    
    trait :suspended do
      suspended { true }
    end
    
    trait :not_suspended do
      suspended { false }
    end
  end
end