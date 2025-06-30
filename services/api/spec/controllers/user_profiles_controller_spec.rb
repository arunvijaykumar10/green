require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do
  describe '#show' do
    let(:user_profile) { create(:user_profile) }
    let(:company) { create(:company) }
    let(:access_role) { create(:access_role, role_type: 'admin') }
    
    before do
      # Create company membership with role
      create(:company_member, 
        profile: user_profile, 
        company: company, 
        access_role: access_role,
        updated_at: 1.day.ago
      )
      
      # Mock authentication
      allow(controller).to receive(:current_user).and_return(user_profile)
      allow(controller).to receive(:authenticate_user).and_return(true)
    end
    
    it 'returns user details with last accessed company and role' do
      get :show
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      
      # Check user details
      expect(json_response['user']['id']).to eq(user_profile.id)
      expect(json_response['user']['email']).to eq(user_profile.email)
      expect(json_response['user']['full_name']).to eq(user_profile.full_name)
      
      # Check company details
      expect(json_response['last_accessed_company']['id']).to eq(company.id)
      expect(json_response['last_accessed_company']['name']).to eq(company.name)
      
      # Check role details
      expect(json_response['role']['id']).to eq(access_role.id)
      expect(json_response['role']['name']).to eq(access_role.name)
      expect(json_response['role']['is_admin']).to eq(true)
    end
    
    context 'when user has multiple company memberships' do
      let(:another_company) { create(:company) }
      let(:another_role) { create(:access_role, role_type: 'employee') }
      
      it 'returns the most recently accessed company' do
        # Create a more recent company membership
        create(:company_member, 
          profile: user_profile, 
          company: another_company, 
          access_role: another_role,
          updated_at: Time.current
        )
        
        get :show
        
        json_response = JSON.parse(response.body)
        expect(json_response['last_accessed_company']['id']).to eq(another_company.id)
        expect(json_response['role']['id']).to eq(another_role.id)
        expect(json_response['role']['is_admin']).to eq(false)
      end
    end
    
    context 'when user has no company memberships' do
      let(:user_without_company) { create(:user_profile) }
      
      it 'returns user details without company or role' do
        allow(controller).to receive(:current_user).and_return(user_without_company)
        
        get :show
        
        json_response = JSON.parse(response.body)
        expect(json_response['user']).to be_present
        expect(json_response['last_accessed_company']).to be_nil
        expect(json_response['role']).to be_nil
      end
    end
  end
end