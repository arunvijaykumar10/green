FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }
    code { "ACC-#{name.parameterize.upcase}-#{SecureRandom.alphanumeric(6)}" }
    
    trait :discarded do
      discarded_at { Time.current }
    end
    
    trait :active do
      discarded_at { nil }
    end
  end
end