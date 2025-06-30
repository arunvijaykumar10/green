json.status "success"
json.message "Company union configurations retrieved successfully"

json.data do
  json.company_union_configurations @company_union_configurations do |config|
    json.extract! config, :id, :union_type, :union_name, :agreement_type, :agreement_type_configuration, :active, :created_at, :updated_at
  end
end