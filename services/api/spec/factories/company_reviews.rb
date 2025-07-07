FactoryBot.define do
  factory :company_review do
    association :company
    status { %w[pending approved rejected].sample }
    reviewed_at { nil }
    review_notes { nil }
    association :reviewed_by, factory: :user_profile

    trait :pending do
      status { 'pending' }
    end

    trait :approved do
      status { 'approved' }
      reviewed_at { Time.current }
    end

    trait :rejected do
      status { 'rejected' }
      reviewed_at { Time.current }
      review_notes { 'Not sufficient' }
    end
  end
end
