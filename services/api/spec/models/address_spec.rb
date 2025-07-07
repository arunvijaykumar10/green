require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'associations' do
    it { should belong_to(:addressable) }
  end

  describe 'validations' do
    subject { build(:address) }
    it { should validate_presence_of(:address_type) }
    it { should validate_inclusion_of(:address_type).in_array(%w[primary billing shipping]) }
    it { should validate_presence_of(:address_line_1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip_code) }
    it { should validate_presence_of(:active_from) }
    it { should validate_presence_of(:country) }
    it { should validate_inclusion_of(:country).in_array(%w[US CA]) }
  end

  describe 'scopes' do
    let!(:primary_address) { create(:address, address_type: 'primary') }
    let!(:billing_address) { create(:address, address_type: 'billing') }
    let!(:active_address) { create(:address, active_from: 2.days.ago, active_until: 1.day.from_now) }
    let!(:inactive_address) { create(:address, active_from: 5.days.ago, active_until: 2.days.ago) }

    describe '.primary' do
      it 'returns only primary addresses' do
        expect(Address.primary).to include(primary_address)
        expect(Address.primary).not_to include(billing_address)
      end
    end

    describe '.active' do
      it 'returns only currently active addresses' do
        expect(Address.active).to include(active_address)
        expect(Address.active).not_to include(inactive_address)
      end
    end
  end

  describe 'address types ' do
    it 'is valid with all required attributes' do
      address = build(:address)
      expect(address).to be_valid
    end
    it 'is valid with country CA' do
      address = build(:address, country: 'CA')
      expect(address).to be_valid
    end
 
    it 'is invalid without address_type' do
      address = build(:address, address_type: nil)
      address.validate
      expect(address.errors[:address_type]).to include("can't be blank")
    end
    it 'is invalid with an invalid address_type' do
      address = build(:address, address_type: 'other')
      address.validate
      expect(address.errors[:address_type]).to include('is not included in the list')
    end
    it 'is invalid without address_line_1' do
      address = build(:address, address_line_1: nil)
      address.validate
      expect(address.errors[:address_line_1]).to include("can't be blank")
    end
    it 'is invalid without city' do
      address = build(:address, city: nil)
      address.validate
      expect(address.errors[:city]).to include("can't be blank")
    end
    it 'is invalid without state' do
      address = build(:address, state: nil)
      address.validate
      expect(address.errors[:state]).to include("can't be blank")
    end
    it 'is invalid without zip_code' do
      address = build(:address, zip_code: nil)
      address.validate
      expect(address.errors[:zip_code]).to include("can't be blank")
    end
    it 'is invalid without active_from' do
      address = build(:address, active_from: nil)
      address.validate
      expect(address.errors[:active_from]).to include("can't be blank")
    end
    it 'is invalid without country' do
      address = build(:address, country: nil)
      address.validate
      expect(address.errors[:country]).to include("can't be blank")
    end
    it 'is invalid with an invalid country' do
      address = build(:address, country: 'IN')
      address.validate
      expect(address.errors[:country]).to include('is not included in the list')
    end
  end
end
