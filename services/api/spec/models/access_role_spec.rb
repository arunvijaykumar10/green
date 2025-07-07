require 'rails_helper'

RSpec.describe AccessRole, type: :model do
  describe 'factories' do
    it 'has a valid default factory' do
      expect(build(:access_role)).to be_valid
    end

    it 'creates a valid admin role' do
      admin_role = build(:access_role, :admin)
      expect(admin_role).to be_valid
      expect(admin_role.name).to eq('Admin')
      expect(admin_role.role_type).to eq('admin')
    end

    it 'creates a valid employee actor role' do
      actor_role = build(:access_role, :actor)
      expect(actor_role).to be_valid
      expect(actor_role.name).to eq('Actor')
      expect(actor_role.category).to eq('union')
      expect(actor_role.role_type).to eq('employee')
    end

    it 'creates unique names with sequence' do
      role1 = create(:access_role)
      role2 = create(:access_role)
      expect(role1.name).not_to eq(role2.name)
    end
  end

  describe 'validations' do
    it 'requires a name' do
      role = build(:access_role, name: nil)
      expect(role).not_to be_valid
      expect(role.errors[:name]).to include("can't be blank")
    end

    it 'requires a role_type' do
      role = build(:access_role, role_type: nil)
      expect(role).not_to be_valid
      expect(role.errors[:role_type]).to include("can't be blank")
    end
  end

  describe 'role types' do
    it 'identifies admin roles' do
      admin_role = create(:access_role, :admin)
      expect(admin_role.role_type).to eq('admin')
    end

    it 'identifies employee roles' do
      employee_role = create(:access_role)
      expect(employee_role.role_type).to eq('employee')
    end
  end
end
