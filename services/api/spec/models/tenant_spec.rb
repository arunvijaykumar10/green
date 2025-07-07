require 'rails_helper'

RSpec.describe Tenant, type: :model do
  describe 'associations' do
    it { should have_many(:companies) }
  end

  describe 'validations' do
    subject { build(:tenant) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }

    context 'name validation' do
      it 'is valid with a name' do
        tenant = build(:tenant, name: 'Valid Company')
        expect(tenant).to be_valid
      end

      it 'is invalid without a name' do
        tenant = build(:tenant, name: nil, code: 'VALID_CODE')
        expect(tenant).not_to be_valid
      end

      it 'is invalid with empty name' do
        tenant = build(:tenant, name: '')
        expect(tenant).not_to be_valid
        expect(tenant.errors[:name]).to include("can't be blank")
      end

      it 'prevents duplicate names' do
        create(:tenant, name: 'Duplicate Name')
        tenant2 = build(:tenant, name: 'Duplicate Name')
        expect(tenant2).not_to be_valid
        expect(tenant2.errors[:name]).to include('has already been taken')
      end

      it 'prevents duplicate names even after discard' do
        tenant1 = create(:tenant, name: 'Same Name')
        tenant1.discard
        tenant2 = build(:tenant, name: 'Same Name')
        expect(tenant2).not_to be_valid
        expect(tenant2.errors[:name]).to include('has already been taken')
      end
    end

    context 'code validation' do
      it 'is valid with a code' do
        tenant = build(:tenant, code: 'VALID_CODE')
        expect(tenant).to be_valid
      end

      it 'is invalid without a code' do
        tenant = build(:tenant, code: nil)
        expect(tenant).not_to be_valid
        expect(tenant.errors[:code]).to include("can't be blank")
      end

      it 'is invalid with empty code' do
        tenant = build(:tenant, code: '')
        expect(tenant).not_to be_valid
        expect(tenant.errors[:code]).to include("can't be blank")
      end

      it 'prevents duplicate codes' do
        create(:tenant, code: 'DUPLICATE_CODE')
        tenant2 = build(:tenant, code: 'DUPLICATE_CODE')
        expect(tenant2).not_to be_valid
        expect(tenant2.errors[:code]).to include('has already been taken')
      end

      it 'prevents duplicate codes even after discard' do
        tenant1 = create(:tenant, code: 'SAME_CODE')
        tenant1.discard
        tenant2 = build(:tenant, code: 'SAME_CODE')
        expect(tenant2).not_to be_valid
        expect(tenant2.errors[:code]).to include('has already been taken')
      end
    end
  end

  describe 'scopes' do
    let!(:active_tenant) { create(:tenant) }
    let!(:discarded_tenant) { create(:tenant, :discarded) }

    describe '.active' do
      it 'returns only active tenants' do
        expect(described_class.active).to include(active_tenant)
        expect(described_class.active).not_to include(discarded_tenant)
      end

      it 'returns empty when no active tenants' do
        described_class.update_all(discarded_at: Time.current)
        expect(described_class.active).to be_empty
      end
    end
  end

  describe 'instance methods' do
    let(:tenant) { build(:tenant) }

    describe '#discard' do
      it 'sets discarded_at timestamp' do
        tenant.save!
        expect { tenant.discard }.to change { tenant.discarded_at }.from(nil)
      end

      it 'marks tenant as discarded' do
        tenant.save!
        tenant.discard
        expect(tenant.discarded_at).to be_present
      end

      it 'prevents creating new tenant with same name after discard' do
        tenant.save!
        original_name = tenant.name
        tenant.discard
        new_tenant = build(:tenant, name: original_name)
        expect(new_tenant).not_to be_valid
      end
    end

    describe '#active?' do
      it 'returns true when tenant is active' do
        tenant.discarded_at = nil
        expect(tenant.active?).to be true
      end

      it 'returns false when tenant is discarded' do
        tenant.discarded_at = Time.current
        expect(tenant.active?).to be false
      end

      it 'returns true for new tenant' do
        new_tenant = build(:tenant)
        expect(new_tenant.active?).to be true
      end
    end
  end

  describe 'soft delete functionality' do
    let!(:tenant) { create(:tenant) }

    it 'soft deletes the record' do
      expect { tenant.discard }.to change { tenant.discarded_at }.from(nil)
    end

    it 'removes from active scope when discarded' do
      tenant.discard
      expect(described_class.active).not_to include(tenant)
    end

    it 'prevents creating new record with same name after soft delete' do
      original_name = tenant.name
      tenant.discard
      new_tenant = build(:tenant, name: original_name)
      expect(new_tenant).not_to be_valid
    end

    it 'prevents creating new record with same code after soft delete' do
      original_code = tenant.code
      tenant.discard
      new_tenant = build(:tenant, code: original_code)
      expect(new_tenant).not_to be_valid
    end
  end
end