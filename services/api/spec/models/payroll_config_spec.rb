require 'rails_helper'

RSpec.describe PayrollConfig, type: :model do
  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'validations' do
    subject { build(:payroll_config) }

    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:frequency) }
    it { should validate_presence_of(:period) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:check_start_number) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without a company' do
      config = build(:payroll_config, company: nil)
      expect(config).not_to be_valid
      expect(config.errors[:company]).to include("can't be blank")
    end

    it 'is invalid without a frequency' do
      config = build(:payroll_config, frequency: nil)
      expect(config).not_to be_valid
      expect(config.errors[:frequency]).to include("can't be blank")
    end

    it 'is invalid without a period' do
      config = build(:payroll_config, period: nil)
      expect(config).not_to be_valid
      expect(config.errors[:period]).to include("can't be blank")
    end

    it 'is invalid without a start_date' do
      config = build(:payroll_config, start_date: nil)
      expect(config).not_to be_valid
      expect(config.errors[:start_date]).to include("can't be blank")
    end

    it 'is invalid without a check_start_number' do
      config = build(:payroll_config, check_start_number: nil)
      expect(config).not_to be_valid
      expect(config.errors[:check_start_number]).to include("can't be blank")
    end
  end

  describe 'scopes' do
    let!(:active_config) { create(:payroll_config, active: true) }
    let!(:inactive_config) { create(:payroll_config, active: false) }
    let!(:approved_config) { create(:payroll_config, approved: true) }
    let!(:pending_config) { create(:payroll_config, approved: false) }

    describe '.active' do
      it 'returns only active payroll configs' do
        expect(PayrollConfig.active).to include(active_config)
        expect(PayrollConfig.active).not_to include(inactive_config)
      end
    end

    describe '.approved' do
      it 'returns only approved payroll configs' do
        expect(PayrollConfig.approved).to include(approved_config)
        expect(PayrollConfig.approved).not_to include(pending_config)
      end
    end

    describe '.pending_approval' do
      it 'returns only pending approval payroll configs' do
        expect(PayrollConfig.pending_approval).to include(pending_config)
        expect(PayrollConfig.pending_approval).not_to include(approved_config)
      end
    end
  end
end
