require 'rails_helper'

RSpec.describe CompanyUnionConfiguration, type: :model do
  let(:company) { create(:company) }

  describe 'validations' do
    it 'validates presence of union_name' do
      config = CompanyUnionConfiguration.new(union_name: nil)
      expect(config).not_to be_valid
      expect(config.errors[:union_name]).to include("can't be blank")
    end

    it 'validates agreement_type inclusion' do
      config = CompanyUnionConfiguration.new(agreement_type: 'invalid')
      expect(config).not_to be_valid
      expect(config.errors[:agreement_type]).to include('is not included in the list')
    end

    context 'collective_bargaining configuration' do
      it 'validates required fields' do
        config = CompanyUnionConfiguration.new(
          company: company,
          union_name: 'Test Union',
          agreement_type: 'collective_bargaining',
          agreement_type_configuration: {
            union_local_number: '123',
            contract_start_date: '2025-01-01',
            contract_end_date: '2025-12-31',
            hourly_rate: 25.00,
            overtime_multiplier: 1.5
          }
        )
        expect(config).to be_valid
      end

      it 'fails validation with missing fields' do
        config = CompanyUnionConfiguration.new(
          company: company,
          union_name: 'Test Union',
          agreement_type: 'collective_bargaining',
          agreement_type_configuration: { union_local_number: '123' }
        )
        expect(config).not_to be_valid
        expect(config.errors[:agreement_type_configuration]).to be_present
      end
    end

    context 'individual_contract configuration' do
      it 'validates required fields' do
        config = CompanyUnionConfiguration.new(
          company: company,
          union_name: 'Test Union',
          agreement_type: 'individual_contract',
          agreement_type_configuration: {
            contract_start_date: '2025-01-01',
            contract_end_date: '2025-12-31',
            base_salary: 50000,
            bonus_structure: 'performance_based'
          }
        )
        expect(config).to be_valid
      end
    end
  end
end