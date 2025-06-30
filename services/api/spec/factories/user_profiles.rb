FactoryBot.define do
  factory :user_profile do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone_no { Faker::PhoneNumber.cell_phone_in_e164 }

    trait :with_phone do
      phone_no { Faker::PhoneNumber.cell_phone_in_e164 }
    end

    trait :without_phone do
      phone_no { nil }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :active do
      discarded_at { nil }
    end
  end
end
