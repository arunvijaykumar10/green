require 'rails_helper'

RSpec.describe Payee, type: :model do
  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:tax_profile).optional }
    it { should have_many(:payee_documents).dependent(:destroy) }
    it { should have_many(:payee_payment_methods).dependent(:destroy) }
    it { should have_many(:onboarding_steps).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:payee) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:payee_type) }
  end

  describe 'payee types' do
    it 'is valid with all required attributes' do
      payee = build(:payee)
      expect(payee).to be_valid
    end

    it 'is invalid without a first_name' do
      payee = build(:payee, first_name: nil)
      expect(payee).not_to be_valid
      expect(payee.errors[:first_name]).to include("can't be blank")
    end
    it 'is invalid without a last_name' do
      payee = build(:payee, last_name: nil)
      expect(payee).not_to be_valid
      expect(payee.errors[:last_name]).to include("can't be blank")
    end
    it 'is invalid without a payee_type' do
      payee = build(:payee, payee_type: nil)
      expect(payee).not_to be_valid
      expect(payee.errors[:payee_type]).to include("can't be blank")
    end
    it 'is invalid without a company' do
      payee = build(:payee, company: nil)
      expect(payee).not_to be_valid
      expect(payee.errors[:company]).to include("must exist")
    end
  end
end
