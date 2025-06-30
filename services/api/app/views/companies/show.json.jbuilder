json.status "success"
json.message "Company details retrieved successfully"

json.data do
  json.company do
    json.extract! @company, :id, :name, :code, :fein, :nys_no, :phone, :signature_type, :company_type, :approved, :created_at, :updated_at
    
    if @company.signature.attached?
      json.signature_url rails_blob_url(@company.signature)
    end
    
    if @company.secondary_signature.attached?
      json.secondary_signature_url rails_blob_url(@company.secondary_signature)
    end

    json.addresses @company.addresses do |address|
      json.extract! address, :id, :address_type, :address_line_1, :address_line_2, :city, :state, :zip_code, :country, :active_from, :active_until
    end

    if policy(@company).show_configs?
      if @company.bank_config
        json.bank_config do
          json.extract! @company.bank_config, :id, :bank_name, :routing_number_ach, :routing_number_wire, :account_number, :authorized, :account_type, :approved, :active
        end
      end

      if @company.company_union_configuration
        json.union_config do
          json.extract! @company.company_union_configuration, :id, :union_type, :union_name, :agreement_type, :agreement_type_configuration, :active, :created_at, :updated_at
        end
      end

      if @company.payroll_config
        json.payroll_config do
          json.extract! @company.payroll_config, :id, :frequency, :period, :start_date, :check_start_number, :approved
        end
      end
    end
  end
end