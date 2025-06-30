json.status "success"
json.message "Companies retrieved successfully"

json.data do
  json.companies @companies do |company|
    json.extract! company, :id, :name, :code, :fein, :nys_no, :phone, :signature_type, :company_type, :approved, :created_at, :updated_at
  end
end