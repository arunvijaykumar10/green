json.status "success"
json.message "Payroll configurations retrieved successfully"

json.data do
  json.payroll_configs @payroll_configs do |payroll_config|
    json.extract! payroll_config, :id, :frequency, :period, :start_date, :check_start_number, :active, :approved, :created_at, :updated_at
  end
end