FactoryBot.define do
  factory :access_role do
    sequence(:name) { |n| "Role #{n}" }
    category { nil }
    role_type { "employee" }

    trait :admin do
      name { "Admin" }
      category { nil }
      role_type { "admin" }
    end

    trait :union_employee do
      name { "Union Employee" }
      category { "union" }
      role_type { "employee" }
    end

    trait :non_union_employee do
      name { "Non-Union Employee" }
      category { "non-union" }
      role_type { "employee" }
    end

    # Specific role examples
    trait :general_manager do
      name { "General Manager" }
      category { nil }
      role_type { "admin" }
    end

    trait :actor do
      name { "Actor" }
      category { "union" }
      role_type { "employee" }
    end

    trait :extra do
      name { "Extra" }
      category { "non-union" }
      role_type { "employee" }
    end
  end
end