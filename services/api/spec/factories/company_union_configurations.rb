FactoryBot.define do
  factory :company_union_configuration do
    union_type { "non-union" }
    active { true }
    association :company

    trait :union do
      union_type { "union" }
      union_name { "SAG-AFTRA" }
      agreement_type { "equity_or_league_production_contract" }
      agreement_type_configuration { {} }
    end
  end
end