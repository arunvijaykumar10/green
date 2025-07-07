require 'rails_helper'

RSpec.describe CompanyAccessLog, type: :model do
  describe 'associations' do
    it { should belong_to(:user_profile) }
    it { should belong_to(:company) }
  end

  describe 'validations' do
    subject { build(:company_access_log) }

    it { should validate_presence_of(:user_profile) }
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:action_type) }
    it { should validate_inclusion_of(:action_type).in_array(["login", "switch_company", "view_dashboard", "logout"]) }
  end
end
