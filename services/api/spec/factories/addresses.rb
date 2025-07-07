FactoryBot.define do
  factory :address do
    association :addressable, factory: :company
    address_type { 'primary' }
    address_line_1 { '123 Main St' }
    city { 'New York' }
    state { 'NY' }
    zip_code { '10001' }
    country { 'US' }
    active_from { 1.day.ago }
    active_until { nil }
  end
end
