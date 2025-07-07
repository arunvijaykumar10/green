FactoryBot.define do
  factory :bank_config do
    bank_name { "Chase Bank" }
    routing_number_ach { "021000021" }
    routing_number_wire { "021000021" }
    account_number { "123456789" }
    account_type { "checking" }
    authorized { true }
    active { true }
    association :company

    trait :unauthorized do
      authorized { false }
    end

    trait :savings do
      account_type { "savings" }
    end

    trait :business do
      bank_name { "Bank of America" }
      account_type { "business" }
    end
  end
end
