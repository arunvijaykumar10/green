FactoryBot.define do
  factory :company_member do
    association :profile, factory: :user_profile
    association :company
    association :access_role, factory: :access_role
    invited_at { Time.current }
    joined_at { 1.day.from_now }
    
    trait :pending do
      joined_at { nil }
    end
    
    trait :joined do
      invited_at { 2.hours.ago }
      joined_at { 1.hour.ago }
    end
    
    trait :admin do
      association :access_role, factory: [:access_role, :admin]
    end
    
    trait :union_employee do
      association :access_role, factory: [:access_role, :union_employee]
    end
    
    trait :non_union_employee do
      association :access_role, factory: [:access_role, :non_union_employee]
    end
  end
end