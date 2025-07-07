require 'rails_helper'

RSpec.describe CompanyReview, type: :model do
  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:reviewed_by).class_name('UserProfile').optional }
  end

  describe 'validations' do
    subject { build(:company_review) }

    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending approved rejected]) }
  end

  describe 'scopes' do
    let!(:pending_review) { create(:company_review, status: 'pending') }
    let!(:approved_review) { create(:company_review, status: 'approved') }
    let!(:rejected_review) { create(:company_review, status: 'rejected') }

    describe '.pending' do
      it 'returns only pending reviews' do
        expect(described_class.pending).to include(pending_review)
        expect(described_class.pending).not_to include(approved_review, rejected_review)
      end
    end

    describe '.approved' do
      it 'returns only approved reviews' do
        expect(described_class.approved).to include(approved_review)
        expect(described_class.approved).not_to include(pending_review, rejected_review)
      end
    end

    describe '.rejected' do
      it 'returns only rejected reviews' do
        expect(described_class.rejected).to include(rejected_review)
        expect(described_class.rejected).not_to include(pending_review, approved_review)
      end
    end
  end

  describe 'instance methods' do
    let(:company_review) { create(:company_review, status: 'pending') }

    describe '#approve!' do
      it 'updates status to approved and sets reviewed_at' do
        company_review.approve!
        expect(company_review.status).to eq('approved')
        expect(company_review.reviewed_at).not_to be_nil
      end
    end

    describe '#reject!' do
      it 'updates status to rejected, sets review_notes and reviewed_at' do
        company_review.reject!('Not sufficient')
        expect(company_review.status).to eq('rejected')
        expect(company_review.review_notes).to eq('Not sufficient')
        expect(company_review.reviewed_at).not_to be_nil
      end
    end
  end

  describe 'callbacks' do
    let(:company_review) { create(:company_review, status: 'pending') }

    it 'enqueues CompanyApprovalJob when status changes to approved' do
      expect {
        company_review.update(status: 'approved')
      }.to have_enqueued_job(CompanyApprovalJob).with(company_review.company_id)
    end
  end
end
