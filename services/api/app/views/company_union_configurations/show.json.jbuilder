json.status "success"
json.message @message

json.data do
  if @company.company_union_configuration
    json.company_union_configuration do
      json.extract! @company.company_union_configuration, :id, :union_type,:union_name, :agreement_type, :agreement_type_configuration, :active, :created_at, :updated_at
    end
  end
end
