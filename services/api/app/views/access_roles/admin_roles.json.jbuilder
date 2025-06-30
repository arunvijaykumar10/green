json.status "success"
json.message "Admin roles retrieved successfully"

json.data do
  json.admin_roles @admin_roles do |role|
    json.extract! role, :id, :name, :category, :role_type, :created_at, :updated_at
  end
end