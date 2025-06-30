json.status "success"
json.message "Please select a company"

json.data do
  json.companies @companies do |company|
    json.id company.id
    json.name company.name
    json.code company.code
  end
end