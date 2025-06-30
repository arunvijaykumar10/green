require 'rails_helper'

RSpec.describe BankConfig, type: :model do
  let(:bank_config) { build(:bank_config) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(bank_config).to be_valid
    end

    # Assuming BankConfig has required fields like name, code, etc.
    it 'is not valid without a name' do
      bank_config.name = nil
      expect(bank_config).not_to be_valid
    end

    it 'is not valid without a bank code' do
      bank_config.code = nil
      expect(bank_config).not_to be_valid
    end
  end

  describe 'associations' do
    # Add these tests if BankConfig has associations
    it { should have_many(:transactions) }
    it { should belong_to(:institution) }
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
    describe '#display_name' do
      it 'returns formatted bank name with code' do
        bank_config.name = "Test Bank"
        bank_config.code = "TB123"
        
        expect(bank_config.display_name).to eq("Test Bank (TB123)")
      end
    end

    describe '#active?' do
      it 'returns true when bank is active' do
        bank_config.active = true
        expect(bank_config.active?).to be true
      end

      it 'returns false when bank is inactive' do
        bank_config.active = false
        expect(bank_config.active?).to be false
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'uppercases the bank code before saving' do
        bank_config.code = "tb123"
        bank_config.save
        expect(bank_config.code).to eq("TB123")
      end
    end
  end
end
