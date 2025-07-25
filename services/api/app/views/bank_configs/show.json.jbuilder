json.status "success"
json.message @message

json.data do
  json.extract! @bank_config, :id, :bank_name, :account_type, :authorized, :routing_number_ach, :routing_number_wire, :account_number, :active, :approved, :created_at, :updated_at
end