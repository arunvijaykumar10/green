require 'rails_helper'

RSpec.describe Current, type: :model do
  describe 'attributes' do
    it 'can set and get user_profile' do
      Current.user_profile = 'user1'
      expect(Current.user_profile).to eq('user1')
    end
    it 'can set and get company' do
      Current.company = 'company1'
      expect(Current.company).to eq('company1')
    end
    it 'can set and get request_id' do
      Current.request_id = 'req-123'
      expect(Current.request_id).to eq('req-123')
    end
    it 'can set and get user_agent' do
      Current.user_agent = 'agent1'
      expect(Current.user_agent).to eq('agent1')
    end
    it 'can set and get ip_address' do
      Current.ip_address = '127.0.0.1'
      expect(Current.ip_address).to eq('127.0.0.1')
    end
  end
end
