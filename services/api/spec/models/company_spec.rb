require 'rails_helper'

RSpec.describe Company, type: :model do
  include ActiveJob::TestHelper
  describe 'associations' do
    it { should belong_to(:tenant) }
    it { should belong_to(:owned_by).class_name('UserProfile') }
    it { should have_many(:company_members).dependent(:destroy) }
    it { should have_many(:user_profiles).through(:company_members).source(:profile) }
    it { should have_one(:bank_config).dependent(:destroy) }
    it { should have_one(:company_union_configuration).dependent(:destroy) }
    it { should have_many(:addresses).dependent(:destroy) }
    it { should have_one(:payroll_config).dependent(:destroy) }
    it { should have_one(:company_review).dependent(:destroy) }
    it { should have_one(:primary_address) }
    it { should have_one_attached(:signature) }
    it { should have_one_attached(:secondary_signature) }
  end

  describe 'validations' do
    subject { build(:company) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }

    context 'on :submit_for_review' do
      it { should validate_inclusion_of(:signature_type).in_array(%w[single double]).on(:submit_for_review) }
      it { should validate_presence_of(:primary_address).on(:submit_for_review) }
      it { should validate_presence_of(:signature).on(:submit_for_review) }

      it 'validates presence of secondary_signature if signature_type is double' do
        company = build(:company, signature_type: 'double', secondary_signature: nil)
        company.valid?(:submit_for_review)
        expect(company.errors[:secondary_signature]).to include("can't be blank")
      end
    end

    context 'on :approval' do
      it { should validate_presence_of(:name).on(:approval) }
      it { should validate_presence_of(:code).on(:approval) }
      it { should validate_presence_of(:fein).on(:approval) }
      it { should validate_presence_of(:company_type).on(:approval) }
      it { should validate_presence_of(:nys_no).on(:approval) }
      it { should validate_presence_of(:phone).on(:approval) }
      it { should validate_presence_of(:primary_address).on(:approval) }
      it { should validate_presence_of(:signature).on(:approval) }

      it 'validates presence of secondary_signature if signature_type is double' do
        company = build(:company, signature_type: 'double', secondary_signature: nil)
        company.valid?(:approval)
        expect(company.errors[:secondary_signature]).to include("can't be blank")
      end
    end

    describe 'custom validation: validate_all_referenced_tables_complete' do
      let(:company) { build(:company) }

      context 'when bank_config is missing' do
        it 'adds error' do
          company.bank_config = nil
          company.valid?(:approval)
          expect(company.errors[:bank_config]).to include('must be present and complete')
        end
      end

      context 'when bank_config is not complete' do
        it 'adds error' do
          incomplete_bank_config = double('BankConfig', complete?: false)
          allow(company).to receive(:bank_config).and_return(incomplete_bank_config)
          company.valid?(:approval)
          expect(company.errors[:bank_config]).to include('must be present and complete')
        end
      end

      context 'when payroll_config is missing' do
        it 'adds error' do
          company.payroll_config = nil
          company.valid?(:approval)
          expect(company.errors[:payroll_config]).to include('must be present and complete')
        end
      end

      context 'when addresses are missing' do
        it 'adds error' do
          allow(company).to receive(:addresses).and_return([])
          company.valid?(:approval)
          expect(company.errors[:addresses]).to include('must have at least one address')
        end
      end

      context 'when union configuration is missing' do
        it 'adds error' do
          company.company_union_configuration = nil
          company.valid?(:approval)
          expect(company.errors[:company_union_configuration]).to include('must have union configuration')
        end
      end

      context 'when signature is missing' do
        it 'adds error' do
          company.signature = nil
          company.valid?(:approval)
          expect(company.errors[:signature]).to include('must have a signature')
        end
      end

      context 'when secondary signature is missing and signature_type is double' do
        it 'adds error' do
          company.signature_type = 'double'
          company.secondary_signature = nil
          company.valid?(:approval)
          expect(company.errors[:secondary_signature]).to include('must have a secondary signature')
        end
      end
    end
  end

  describe 'scopes' do
    let!(:active_company) { create(:company) }
    let!(:inactive_company) { create(:company, discarded_at: Time.current) }
    let!(:approved_company) { create(:company, approved: true) }
    let!(:pending_company) { create(:company, approved: false) }

    describe '.active' do
      it 'returns only active companies' do
        expect(Company.active).to include(active_company)
        expect(Company.active).not_to include(inactive_company)
      end

      it 'uses kept scope' do
        expect(Company.active).to eq(Company.kept)
      end
    end

    describe '.approved' do
      it 'returns only approved companies' do
        expect(Company.approved).to include(approved_company)
        expect(Company.approved).not_to include(pending_company)
      end
    end

    describe '.pending_approval' do
      it 'returns only companies pending approval' do
        expect(Company.pending_approval).to include(pending_company)
        expect(Company.pending_approval).not_to include(approved_company)
      end
    end
  end

  describe 'instance methods' do
    describe '#validate_for_review' do
      it 'returns true if valid for review' do
        company = build(:company)
        allow(company).to receive(:valid?).with(:submit_for_review).and_return(true)
        expect(company.validate_for_review).to be true
      end
    end

    describe '#submit_for_review!' do
      it 'creates a company_review if valid for review' do
        company = create(:company)
        allow(company).to receive(:validate_for_review).and_return(true)
        expect {
          company.submit_for_review!
        }.to change { CompanyReview.count }.by(1)
      end
    end

    describe '#review_status_info' do
      it 'returns not_submitted if no review exists' do
        company = build(:company, company_review: nil)
        expect(company.review_status_info[:status]).to eq('not_submitted')
      end
    end

    describe 'approval flow' do
      it 'approves company and all related configs through review' do
        company = create(:company)
        bank_config = create(:bank_config, company: company)
        payroll_config = create(:payroll_config, company: company)
        union_config = create(:company_union_configuration, company: company)
        company_review = create(:company_review, company: company, status: 'pending')
        
        perform_enqueued_jobs do
          company_review.approve!
        end

        expect(company.reload.approved).to be true
        expect(bank_config.reload.approved).to be true
        expect(payroll_config.reload.approved).to be true
        expect(union_config.reload.approved).to be true
      end
    end
  end
end
