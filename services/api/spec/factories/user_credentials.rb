FactoryBot.define do
  factory :user_credential do
    association :user_profile
    subject { Faker::Internet.uuid }

    trait :with_first_login do
      first_login_at { Time.current }
    end

    trait :without_first_login do
      first_login_at { nil }
    end
  end
end