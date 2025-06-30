require "test_helper"

class CompanyUnionConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should create company union configuration" do
    post "/companies/1/company_union_configurations", params: {
      company_union_configuration: {
        union_name: "Test Union",
        agreement_type: "collective_bargaining",
        agreement_type_configuration: {
          union_local_number: "123",
          contract_start_date: "2025-01-01",
          contract_end_date: "2025-12-31",
          hourly_rate: "25.00",
          overtime_multiplier: "1.5"
        }
      }
    }, headers: { "Content-Type": "application/json" }
    
    assert_response :created
  end
end