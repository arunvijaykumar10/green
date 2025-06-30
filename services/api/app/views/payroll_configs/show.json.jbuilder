json.status "success"
json.message @message

json.data do
  json.payroll_config do
    json.extract! @payroll_config, :id, :frequency, :period, :start_date, :check_start_number, :approved, :created_at, :updated_at
  end
end