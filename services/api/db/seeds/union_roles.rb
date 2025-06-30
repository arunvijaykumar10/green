# db/seeds/union_roles.rb

# Actors Equity Association job titles (Union) with category="union" and role_type="employee"
union_roles = [
  "Actor (General Title)",
  "Star",
  "Principal Actor",
  "Chorus/Swing",
  "General Understudy",
  "Stage Manager (General Title)",
  "Production Stage Manager",
  "1st Assistant Stage Manager",
  "2nd Assistant Stage Manager"
]

union_roles.each do |role_name|
  AccessRole.find_or_create_by!(name: role_name) do |role|
    role.category = "union"
    role.role_type = "employee"
  end
end

puts "✅ Union employee roles created successfully"