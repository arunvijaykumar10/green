FactoryBot.define do
  factory :payee do
    association :company
    first_name { 'John' }
    last_name  { 'Doe' }
    payee_type { 'employee' }
    tax_profile { nil }

    trait :with_employee_tax_profile do
      association :tax_profile, factory: :employee_tax_profile
      tax_profile_type { 'EmployeeTaxProfile' }
    end
  end
end
