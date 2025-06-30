# db/seeds/non_union_roles.rb

# Generic job titles (Non-union) with category="non-union" and role_type="employee"
non_union_roles = [
  "TBD"  # To be determined/defined
]

non_union_roles.each do |role_name|
  AccessRole.find_or_create_by!(name: role_name) do |role|
    role.category = "non-union"
    role.role_type = "employee"
  end
end

puts "✅ Non-union employee roles created successfully"