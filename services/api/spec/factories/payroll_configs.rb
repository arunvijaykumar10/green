FactoryBot.define do
  factory :payroll_config do
    association :company
    frequency { 'monthly' }
    period { '2025-07' }
    start_date { Date.today }
    check_start_number { 1000 }
    active { true }
    approved { true }
  end
end
