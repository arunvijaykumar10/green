json.status "success"

json.data do
  json.access_role do
    json.extract! @access_role, :id, :name, :category, :role_type, :created_at, :updated_at
  end
end
