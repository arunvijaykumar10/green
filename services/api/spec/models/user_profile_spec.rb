require 'rails_helper'
# spec/models/user_profile_spec.rb

require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  describe 'associations' do
    it { should have_one(:user_credential).dependent(:destroy) }
    it { should have_many(:company_members).with_foreign_key('profile_id').dependent(:destroy) }
    it { should have_many(:companies).through(:company_members) }
  end

  describe 'validations' do
    subject { build(:user_profile) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).scoped_to(:discarded_at) }

    context 'email format' do
      it 'is valid with a proper email format' do
        user_profile = build(:user_profile, email: 'test@example.com')
        expect(user_profile).to be_valid
      end

      it 'is invalid with improper email format' do
        user_profile = build(:user_profile, email: 'invalid-email')
        expect(user_profile).not_to be_valid
        expect(user_profile.errors[:email]).to include('is invalid')
      end
    end

    context 'phone number format' do
      it 'is valid with numbers only' do
        user_profile = build(:user_profile, phone_no: '1234567890')
        expect(user_profile).to be_valid
      end

      it 'is valid with plus prefix' do
        user_profile = build(:user_profile, phone_no: '+1234567890')
        expect(user_profile).to be_valid
      end

      it 'is invalid with letters' do
        user_profile = build(:user_profile, phone_no: '123abc456')
        expect(user_profile).not_to be_valid
        expect(user_profile.errors[:phone_no]).to include('only allows numbers and optional + prefix')
      end
    end
  end

  describe 'scopes' do
    let!(:active_profile) { create(:user_profile) }
    let!(:inactive_profile) { create(:user_profile, discarded_at: Time.current) }

    describe '.active' do
      it 'returns only active profiles' do
        expect(described_class.active).to include(active_profile)
        expect(described_class.active).not_to include(inactive_profile)
      end
    end

    describe '.inactive' do
      it 'returns only inactive profiles' do
        expect(described_class.inactive).to include(inactive_profile)
        expect(described_class.inactive).not_to include(active_profile)
      end
    end
  end

  describe 'instance methods' do
    let(:user_profile) { build(:user_profile, first_name: 'John', last_name: 'Doe') }

    describe '#full_name' do
      it 'returns the combined first and last name' do
        expect(user_profile.full_name).to eq('John Doe')
      end
    end

    describe '#super_admin?' do
      it 'returns true when user is super admin' do
        user_profile.super_admin = true
        expect(user_profile.super_admin?).to be true
      end

      it 'returns false when user is not super admin' do
        user_profile.super_admin = false
        expect(user_profile.super_admin?).to be false
      end
    end

    describe '#admin?' do
      let(:user_profile) { create(:user_profile) }

      it 'returns true when user has admin role' do
        create(:company_member, profile: user_profile, access_role: create(:access_role, role_type: 'admin'))
        expect(user_profile.admin?).to be true
      end

      it 'returns false when user does not have admin role' do
        create(:company_member, profile: user_profile, access_role: create(:access_role, role_type: 'employee'))
        expect(user_profile.admin?).to be false
      end
    end

    describe '#employee?' do
      let(:user_profile) { create(:user_profile) }

      it 'returns true when user is neither super admin nor admin' do
        allow(user_profile).to receive(:super_admin?).and_return(false)
        allow(user_profile).to receive(:admin?).and_return(false)
        expect(user_profile.employee?).to be true
      end

      it 'returns false when user is super admin' do
        allow(user_profile).to receive(:super_admin?).and_return(true)
        allow(user_profile).to receive(:admin?).and_return(false)
        expect(user_profile.employee?).to be false
      end

      it 'returns false when user is admin' do
        allow(user_profile).to receive(:super_admin?).and_return(false)
        allow(user_profile).to receive(:admin?).and_return(true)
        expect(user_profile.employee?).to be false
      end
    end
    
    describe 'cross-company roles' do
      let(:user_profile) { create(:user_profile) }
      let(:company1) { create(:company) }
      let(:company2) { create(:company) }
      let(:company3) { create(:company) }
      let(:admin_role) { create(:access_role, role_type: 'admin') }
      let(:employee_role) { create(:access_role, role_type: 'employee') }
      
      it 'allows a user to be admin for one company and regular user for another' do
        # Create user as admin for company1
        create(:company_member, profile: user_profile, company: company1, access_role: admin_role)
        
        # Create user as employee for company2
        create(:company_member, profile: user_profile, company: company2, access_role: employee_role)
        
        # Verify user is admin for company1
        expect(user_profile.admin?).to be true
        
        # Verify user is associated with both companies
        expect(user_profile.companies).to include(company1, company2)
        
        # Verify company associations
        expect(company1.company_members.where(profile: user_profile).first.access_role).to eq(admin_role)
        expect(company2.company_members.where(profile: user_profile).first.access_role).to eq(employee_role)
      end
      
      it 'allows a user to be admin for multiple companies' do
        # Create user as admin for company1 and company3
        create(:company_member, profile: user_profile, company: company1, access_role: admin_role)
        create(:company_member, profile: user_profile, company: company3, access_role: admin_role)
        
        # Verify user is admin (has at least one admin role)
        expect(user_profile.admin?).to be true
        
        # Verify user is associated with both companies
        expect(user_profile.companies).to include(company1, company3)
        
        # Verify both company associations have admin role
        expect(company1.company_members.where(profile: user_profile).first.access_role).to eq(admin_role)
        expect(company3.company_members.where(profile: user_profile).first.access_role).to eq(admin_role)
      end
      
      it 'allows different users to have different roles for the same company' do
        # Create another user profile
        another_user = create(:user_profile)
        
        # First user is admin for company1
        create(:company_member, profile: user_profile, company: company1, access_role: admin_role)
        
        # Second user is employee for company1
        create(:company_member, profile: another_user, company: company1, access_role: employee_role)
        
        # Verify first user is admin
        expect(user_profile.admin?).to be true
        
        # Verify second user is not admin
        expect(another_user.admin?).to be false
        
        # Verify both users are associated with company1
        expect(company1.company_members.map(&:profile)).to include(user_profile, another_user)
      end
    end
  end
end

# RSpec.describe UserProfile, type: :model do
#   describe 'validations' do
#     subject { build(:user_profile) }

#     it { should validate_presence_of(:first_name) }
#     it { should validate_presence_of(:last_name) }
#     it { should validate_presence_of(:email) }

#     context 'email uniqueness' do
#       subject { create(:user_profile) }
#       it { should validate_uniqueness_of(:email).scoped_to(:discarded_at) }
#     end

#     context 'phone number format' do
#       it 'accepts valid phone numbers' do
#         valid_numbers = [ '+1234567890', '1234567890' ]
#         valid_numbers.each do |number|
#           user = build(:user_profile, phone_no: number)
#           expect(user).to be_valid
#         end
#       end

#       it 'rejects invalid phone numbers' do
#         invalid_numbers = [ 'abc123', '123-456-7890', '123.456.7890', '123 456 7890' ]
#         invalid_numbers.each do |number|
#           user = build(:user_profile, phone_no: number)
#           expect(user).not_to be_valid
#           expect(user.errors[:phone_no]).to include('only allows numbers and optional + prefix')
#         end
#       end

#       it 'allows nil phone number' do
#         user = build(:user_profile, phone_no: nil)
#         expect(user).to be_valid
#       end
#     end
#   end

#   describe 'scopes' do
#     let!(:active_user) { create(:user_profile) }
#     let!(:inactive_user) { create(:user_profile, :discarded) }

#     describe '.active' do
#       it 'returns only active users' do
#         expect(described_class.active).to include(active_user)
#         expect(described_class.active).not_to include(inactive_user)
#       end
#     end

#     describe '.inactive' do
#       it 'returns only inactive users' do
#         expect(described_class.inactive).to include(inactive_user)
#         expect(described_class.inactive).not_to include(active_user)
#       end
#     end
#   end

#   describe '#full_name' do
#     let(:user) { build(:user_profile, first_name: 'John', last_name: 'Doe') }

#     it 'returns the full name' do
#       expect(user.full_name).to eq('John Doe')
#     end

#     it 'handles empty names' do
#       user.first_name = ''
#       user.last_name = ''
#       expect(user.full_name).to eq(' ')
#     end
#   end

#   describe 'soft delete functionality' do
#     let!(:user) { create(:user_profile) }

#     it 'soft deletes the record' do
#       expect {
#         user.discard
#       }.to change { user.discarded? }.from(false).to(true)
#         .and change { user.discarded_at }.from(nil)
#     end

#     it 'restores the record' do
#       user.discard
#       expect {
#         user.undiscard
#       }.to change { user.discarded? }.from(true).to(false)
#         .and change { user.discarded_at }.to(nil)
#     end

#     it 'allows creating a new record with same email after soft delete' do
#       user.discard
#       new_user = build(:user_profile, email: user.email)
#       expect(new_user).to be_valid
#     end

#     it 'prevents creating a new record with same email for active users' do
#       new_user = build(:user_profile, email: user.email)
#       expect(new_user).not_to be_valid
#       expect(new_user.errors[:email]).to include('has already been taken')
#     end
#   end
# end
