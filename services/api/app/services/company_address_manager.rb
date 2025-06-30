# == app/services/company_address_manager.rb ==
class CompanyAddressManager
  def initialize(company)
    @company = company
  end

  def add_address(params)
    Company.transaction do
      deactivate_current_addresses
      @company.company_addresses.create!(params.merge(active_from: Time.current))
    end
  end

  def deactivate_current_addresses
    @company.company_addresses.current.update_all(active_until: Time.current)
  end
end
