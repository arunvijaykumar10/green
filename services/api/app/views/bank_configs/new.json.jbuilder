json.status "success"
json.message "New bank configuration form"

json.data do
  json.bank_configs do
    json.extract! @bank_config, :id, :bank_name, :account_type, :active
  end
end