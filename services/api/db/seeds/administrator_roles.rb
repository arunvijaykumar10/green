# db/seeds/administrator_roles.rb

# Administrator roles with category=null and role_type=admin
admin_roles = [
  "General Manager",
  "Assistant/Associate General Manager",
  "Company Manager",
  "Assistant/Associate Company Manager",
  "Accountant",
  "Bookkeeper",
  "Finance Director/Manager",
  "Producer",
  "Custom or Other Authorized Member"
]

admin_roles.each do |role_name|
  AccessRole.find_or_create_by!(name: role_name) do |role|
    role.category = nil
    role.role_type = "admin"
  end
end

puts "✅ Administrator roles created successfully"