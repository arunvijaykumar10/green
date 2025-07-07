require 'rails_helper'

RSpec.describe CompanyUnionConfiguration, type: :model do
  let(:company) { create(:company) }
  let(:union_config) { build(:company_union_configuration, company: company, union_type: 'union') }
  let(:non_union_config) { build(:company_union_configuration, company: company, union_type: 'non-union') }

  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'validations' do
    describe 'union_type' do
      it 'validates presence' do
        config = build(:company_union_configuration, union_type: nil)
        expect(config).not_to be_valid
        expect(config.errors[:union_type]).to include("can't be blank")
      end

      it 'validates inclusion' do
        config = build(:company_union_configuration, union_type: 'invalid')
        expect(config).not_to be_valid
        expect(config.errors[:union_type]).to include('is not included in the list')
      end

      it 'accepts valid union types' do
        union_config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union', 
          agreement_type: '29_hour_reading'
        )
        expect(union_config).to be_valid
        
        non_union_config = build(:company_union_configuration, union_type: 'non-union')
        expect(non_union_config).to be_valid
      end
    end

    describe 'union_name' do
      it 'is required when union_type is union' do
        config = build(:company_union_configuration, union_type: 'union', union_name: nil)
        expect(config).not_to be_valid
        expect(config.errors[:union_name]).to include("can't be blank")
      end

      it 'is not required when union_type is non-union' do
        config = build(:company_union_configuration, union_type: 'non-union', union_name: nil)
        expect(config).to be_valid
      end
    end

    describe 'agreement_type' do
      it 'is required when union_type is union' do
        config = build(:company_union_configuration, union_type: 'union', agreement_type: nil)
        expect(config).not_to be_valid
        expect(config.errors[:agreement_type]).to include("can't be blank")
      end

      it 'validates inclusion when union_type is union' do
        config = build(:company_union_configuration, union_type: 'union', agreement_type: 'invalid')
        expect(config).not_to be_valid
        expect(config.errors[:agreement_type]).to include('is not included in the list')
      end

      it 'accepts valid agreement types' do
        # Test 29_hour_reading (no config required)
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: '29_hour_reading'
        )
        expect(config).to be_valid
        
        # Test equity_or_league_production_contract
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: 'equity_or_league_production_contract',
          agreement_type_configuration: {
            musical_or_dramatic: 'musical',
            aea_employer_id: 'EMP123',
            aea_production_title: 'Test Production',
            aea_business_representative: 'John Doe'
          }
        )
        expect(config).to be_valid
        
        # Test development_agreement
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: 'development_agreement',
          agreement_type_configuration: {
            tier: 'tier1',
            aea_employer_id: 'EMP123',
            aea_production_title: 'Test Production',
            aea_business_representative: 'John Doe'
          }
        )
        expect(config).to be_valid
      end

      it 'is not required when union_type is non-union' do
        config = build(:company_union_configuration, union_type: 'non-union', agreement_type: nil)
        expect(config).to be_valid
      end
    end

    describe 'agreement_type_configuration' do
      it 'is required for equity_or_league_production_contract' do
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: 'equity_or_league_production_contract', 
          agreement_type_configuration: nil
        )
        expect(config).not_to be_valid
        expect(config.errors[:agreement_type_configuration]).to include("can't be blank")
      end

      it 'is required for off_broadway_agreement' do
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: 'off_broadway_agreement', 
          agreement_type_configuration: nil
        )
        expect(config).not_to be_valid
        expect(config.errors[:agreement_type_configuration]).to include("can't be blank")
      end

      it 'is required for development_agreement' do
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: 'development_agreement', 
          agreement_type_configuration: nil
        )
        expect(config).not_to be_valid
        expect(config.errors[:agreement_type_configuration]).to include("can't be blank")
      end

      it 'is not required for 29_hour_reading' do
        config = build(:company_union_configuration, 
          union_type: 'union', 
          union_name: 'Test Union',
          agreement_type: '29_hour_reading', 
          agreement_type_configuration: nil
        )
        expect(config).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:active_config) { create(:company_union_configuration, union_type: 'non-union', active: true) }
    let!(:inactive_config) { create(:company_union_configuration, union_type: 'non-union', active: false) }
    let!(:approved_config) { create(:company_union_configuration, union_type: 'non-union', approved: true) }
    let!(:pending_config) { create(:company_union_configuration, union_type: 'non-union', approved: false) }
    let!(:equity_config) { create(:company_union_configuration, 
      union_type: 'union',
      union_name: 'Test Union',
      agreement_type: 'equity_or_league_production_contract',
      agreement_type_configuration: {
        musical_or_dramatic: 'musical',
        aea_employer_id: 'EMP123',
        aea_production_title: 'Test Production',
        aea_business_representative: 'John Doe'
      }
    ) }

    describe '.active' do
      it 'returns only active configurations' do
        expect(CompanyUnionConfiguration.active).to include(active_config)
        expect(CompanyUnionConfiguration.active).not_to include(inactive_config)
      end
    end

    describe '.approved' do
      it 'returns only approved configurations' do
        expect(CompanyUnionConfiguration.approved).to include(approved_config)
        expect(CompanyUnionConfiguration.approved).not_to include(pending_config)
      end
    end

    describe '.pending_approval' do
      it 'returns only pending approval configurations' do
        expect(CompanyUnionConfiguration.pending_approval).to include(pending_config)
        expect(CompanyUnionConfiguration.pending_approval).not_to include(approved_config)
      end
    end

    describe '.by_agreement_type' do
      it 'returns configurations by agreement type' do
        expect(CompanyUnionConfiguration.by_agreement_type('equity_or_league_production_contract')).to include(equity_config)
      end
    end
  end

  describe 'callbacks' do
    describe '#clear_union_fields_if_non_union' do
      it 'clears union fields when union_type is non-union' do
        config = build(:company_union_configuration, 
          union_type: 'union',
          union_name: 'Test Union',
          agreement_type: 'equity_or_league_production_contract',
          agreement_type_configuration: { test: 'data' }
        )
        config.union_type = 'non-union'
        config.valid?
        
        expect(config.union_name).to be_nil
        expect(config.agreement_type).to be_nil
        expect(config.agreement_type_configuration).to be_nil
      end

      it 'does not clear fields when union_type is union' do
        config = build(:company_union_configuration,
          union_type: 'union',
          union_name: 'Test Union',
          agreement_type: 'equity_or_league_production_contract'
        )
        config.valid?
        
        expect(config.union_name).to eq('Test Union')
        expect(config.agreement_type).to eq('equity_or_league_production_contract')
      end
    end
  end
end