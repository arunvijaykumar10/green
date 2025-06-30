json.status "success"
json.message "Employee roles retrieved successfully"

json.data do
  json.union_roles @union_roles do |role|
    json.extract! role, :id, :name, :category, :role_type, :created_at, :updated_at
  end
  
  json.non_union_roles @non_union_roles do |role|
    json.extract! role, :id, :name, :category, :role_type, :created_at, :updated_at
  end
end