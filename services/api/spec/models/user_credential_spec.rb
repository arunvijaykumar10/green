require 'rails_helper'

RSpec.describe UserCredential, type: :model do
  describe 'associations' do
    it { should belong_to(:user_profile) }
  end

  describe 'validations' do
    subject { build(:user_credential) }

    it { should validate_presence_of(:subject) }
    it { should validate_uniqueness_of(:subject).scoped_to(:user_profile_id) }
    it { should validate_uniqueness_of(:user_profile) }

    context 'subject validation' do
      it 'is valid with a subject' do
        credential = build(:user_credential, subject: 'valid_subject')
        expect(credential).to be_valid
      end

      it 'is invalid without a subject' do
        credential = build(:user_credential, subject: nil)
        expect(credential).not_to be_valid
        expect(credential.errors[:subject]).to include("can't be blank")
      end

      it 'allows same subject for different user profiles' do
        profile1 = create(:user_profile)
        profile2 = create(:user_profile)
        create(:user_credential, subject: 'same_subject', user_profile: profile1)
        credential2 = build(:user_credential, subject: 'same_subject', user_profile: profile2)
        expect(credential2).to be_valid
      end

      it 'prevents duplicate subject for same user profile' do
        profile = create(:user_profile)
        create(:user_credential, subject: 'duplicate_subject', user_profile: profile)
        credential2 = build(:user_credential, subject: 'duplicate_subject', user_profile: profile)
        expect(credential2).not_to be_valid
        expect(credential2.errors[:subject]).to include('has already been taken')
      end
    end

    context 'user_profile validation' do
      it 'is valid with a user profile' do
        credential = build(:user_credential)
        expect(credential).to be_valid
      end

      it 'is invalid without a user profile' do
        credential = build(:user_credential, user_profile: nil)
        expect(credential).not_to be_valid
        expect(credential.errors[:user_profile]).to include("must exist")
      end

      it 'prevents multiple credentials for same user profile' do
        profile = create(:user_profile)
        create(:user_credential, user_profile: profile)
        credential2 = build(:user_credential, user_profile: profile)
        expect(credential2).not_to be_valid
        expect(credential2.errors[:user_profile]).to include('has already been taken')
      end
    end
  end
  describe 'scopes' do
    let!(:credential_with_login) { create(:user_credential) }
    let!(:credential_without_login) { create(:user_credential).tap { |c| c.update_column(:first_login_at, nil) } }

    describe '.with_first_login' do
      it 'returns only credentials with first login' do
        expect(described_class.with_first_login).to include(credential_with_login)
        expect(described_class.with_first_login).not_to include(credential_without_login)
      end
    end

    describe '.without_first_login' do
      it 'returns only credentials without first login' do
        expect(described_class.without_first_login).to include(credential_without_login)
        expect(described_class.without_first_login).not_to include(credential_with_login)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_create :set_first_login_at' do
      it 'sets first_login_at when creating a new credential' do
        credential = build(:user_credential, first_login_at: nil)
        expect { credential.save! }.to change { credential.first_login_at }.from(nil)
      end

      it 'does not override existing first_login_at' do
        existing_time = 1.day.ago
        credential = build(:user_credential, first_login_at: existing_time)
        credential.save!
        expect(credential.first_login_at).to be_within(1.second).of(existing_time)
      end
    end
  end
end