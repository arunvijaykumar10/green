require 'rails_helper'

RSpec.describe BankConfig, type: :model do
  let(:bank_config) { build(:bank_config) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(bank_config).to be_valid
    end

    it 'is not valid without a bank_name' do
      bank_config.bank_name = nil
      expect(bank_config).not_to be_valid
    end

    it 'is not valid without an account_number' do
      bank_config.account_number = nil
      expect(bank_config).not_to be_valid
    end

    it 'is not valid without routing_number_ach' do
      bank_config.routing_number_ach = nil
      expect(bank_config).not_to be_valid
    end

    it 'is not valid without routing_number_wire' do
      bank_config.routing_number_wire = nil
      expect(bank_config).not_to be_valid
    end

    it 'validates routing_number_ach format' do
      bank_config.routing_number_ach = '12345'
      expect(bank_config).not_to be_valid
      expect(bank_config.errors[:routing_number_ach]).to include('must be 9 digits')
    end

    it 'validates routing_number_wire format' do
      bank_config.routing_number_wire = '12345'
      expect(bank_config).not_to be_valid
      expect(bank_config.errors[:routing_number_wire]).to include('must be 9 digits')
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active bank configs' do
        active_bank = create(:bank_config, active: true)
        inactive_bank = create(:bank_config, active: false)
        
        expect(BankConfig.active).to include(active_bank)
        expect(BankConfig.active).not_to include(inactive_bank)
      end
    end
  end

  describe 'instance methods' do
    describe '#complete?' do
      it 'returns true when all required fields are present' do
        expect(bank_config.complete?).to be true
      end

      it 'returns false when bank_name is missing' do
        bank_config.bank_name = nil
        expect(bank_config.complete?).to be false
      end
    end
  end
end
