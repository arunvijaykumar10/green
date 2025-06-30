require 'rails_helper'

RSpec.describe 'CompanyUnionConfigurations', type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      union_name: 'Test Union',
      agreement_type: 'collective_bargaining',
      agreement_type_configuration: {
        union_local_number: '123',
        contract_start_date: '2025-01-01',
        contract_end_date: '2025-12-31',
        hourly_rate: '25.00',
        overtime_multiplier: '1.5'
      }
    }
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'POST /companies/:company_id/company_union_configurations' do
    it 'creates a new company union configuration' do
      post "/companies/#{company.id}/company_union_configurations",
           params: { company_union_configuration: valid_attributes },
           headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end

    it 'returns errors for invalid data' do
      post "/companies/#{company.id}/company_union_configurations",
           params: { company_union_configuration: { union_name: '' } },
           headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['status']).to eq('error')
    end
  end
end