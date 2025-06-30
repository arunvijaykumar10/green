FactoryBot.define do
  factory :bank_config do
    name { "Chase Bank" }
    routing_no { "021000021" }
    acc_no { "123456789" }
    acc_type { "checking" }
    is_authorized { true }
    association :company

    trait :unauthorized do
      is_authorized { false }
    end

    trait :savings do
      acc_type { "savings" }
    end

    trait :business do
      name { "Bank of America" }
      acc_type { "business" }
    end
  end
end
