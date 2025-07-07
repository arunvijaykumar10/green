require 'rails_helper'

RSpec.describe CompanyMember, type: :model do
  describe 'associations' do
    it { should belong_to(:profile).class_name('UserProfile') }
    it { should belong_to(:company) }
    it { should belong_to(:access_role).class_name('AccessRole').optional }
  end

  describe 'validations' do
    subject { build(:company_member) }

    it { should validate_uniqueness_of(:profile_id).scoped_to(:company_id) }

    context 'joined_at_after_invited_at' do
      it 'is valid if joined_at is after invited_at' do
        member = build(:company_member, invited_at: 2.days.ago, joined_at: 1.day.ago)
        expect(member).to be_valid
      end

      it 'is invalid if joined_at is before or equal to invited_at' do
        member = build(:company_member, invited_at: 1.day.ago, joined_at: 2.days.ago)
        expect(member).not_to be_valid
        expect(member.errors[:joined_at]).to include('must be after invited_at')
      end
    end
  end

  describe 'scopes' do
    let!(:active_member) { create(:company_member) }
    let!(:inactive_member) { create(:company_member, discarded_at: Time.current) }
    let!(:invited_member) { create(:company_member, :pending) }
    let!(:joined_member) { create(:company_member, :joined) }

    describe '.active' do
      it 'returns only active members' do
        expect(described_class.active).to include(active_member)
        expect(described_class.active).not_to include(inactive_member)
      end
    end

    describe '.inactive' do
      it 'returns only inactive members' do
        expect(described_class.inactive).to include(inactive_member)
        expect(described_class.inactive).not_to include(active_member)
      end
    end

    describe '.invited' do
      it 'returns only invited members' do
        expect(described_class.invited).to include(invited_member)
        expect(described_class.invited).not_to include(joined_member)
      end
    end

    describe '.joined' do
      it 'returns only joined members' do
        expect(described_class.joined).to include(joined_member)
        expect(described_class.joined).not_to include(invited_member)
      end
    end
  end

  describe 'callbacks' do
    it 'sets invited_at before validation on create if not set' do
      member = build(:company_member, invited_at: nil)
      member.valid?
      expect(member.invited_at).not_to be_nil
    end
  end
end
