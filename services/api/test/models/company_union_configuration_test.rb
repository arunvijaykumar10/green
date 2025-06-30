require "test_helper"

class CompanyUnionConfigurationTest < ActiveSupport::TestCase
  test "should validate collective_bargaining configuration" do
    config = CompanyUnionConfiguration.new(
      union_name: "Test Union",
      agreement_type: "collective_bargaining",
      agreement_type_configuration: {
        union_local_number: "123",
        contract_start_date: "2025-01-01",
        contract_end_date: "2025-12-31",
        hourly_rate: "25.00",
        overtime_multiplier: "1.5"
      }
    )
    assert config.valid?
  end

  test "should validate individual_contract configuration" do
    config = CompanyUnionConfiguration.new(
      union_name: "Test Union",
      agreement_type: "individual_contract",
      agreement_type_configuration: {
        contract_start_date: "2025-01-01",
        contract_end_date: "2025-12-31",
        base_salary: "50000",
        bonus_structure: "performance_based"
      }
    )
    assert config.valid?
  end
end