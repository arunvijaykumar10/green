# spec/controllers/user_registrations_controller_spec.rb

require 'rails_helper'

RSpec.describe UserRegistrationsController, type: :controller do
  describe '#register' do
    let(:valid_user_profile_params) do
      {
        user_profile: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com'
        }
      }
    end

    let(:valid_company_params) do
      {
        company: {
          name: 'Test Company',
          company_type: 'business'
        }
      }
    end

    let(:valid_params) { valid_user_profile_params.merge(valid_company_params) }
    let(:mock_subject) { 'mock-cognito-subject-id' }

    before do
      # Default stub for successful authentication
      allow_any_instance_of(UserRegistrationsController).to receive(:get_subject_from_auth_header).and_return(mock_subject)
    end

    context 'when authentication fails' do
      it 'returns unauthorized status' do
        # Create a new instance of the test for isolation
        allow(controller).to receive(:get_subject_from_auth_header).and_return(nil)
        post :register, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when validation fails' do
      let(:invalid_params) do
        valid_params.deep_merge(
          user_profile: { email: 'invalid-email' }
        )
      end

      it 'returns unprocessable entity status with error messages' do
        # Force validation error by making email invalid
        allow_any_instance_of(UserProfile).to receive(:valid?).and_return(false)
        allow_any_instance_of(UserProfile).to receive_message_chain(:errors, :full_messages).and_return(['Email is invalid'])
        allow_any_instance_of(UserProfile).to receive_message_chain(:errors, :any?).and_return(true)

        post :register, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Email is invalid")
      end

      it 'does not create any records when transaction fails' do
        expect {
          begin
            post :register, params: invalid_params
          rescue ValidationFailed
            nil
          end
        }.to change(UserProfile, :count).by(0)
          .and change(Company, :count).by(0)
          .and change(CompanyMember, :count).by(0)
          .and change(Tenant, :count).by(0)
          .and change(UserCredential, :count).by(0)
      end
    end

    context 'with missing parameters' do
      it 'raises ActionController::ParameterMissing for missing user_profile' do
        expect {
          post :register, params: { company: valid_company_params[:company] }
        }.to raise_error(ActionController::ParameterMissing)
      end

      it 'raises ActionController::ParameterMissing for missing company' do
        expect {
          post :register, params: { user_profile: valid_user_profile_params[:user_profile] }
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context 'when all parameters are valid' do
      it 'creates user profile, company, and associated records' do
        expect {
          post :register, params: valid_params
        }.to change(UserProfile, :count).by(1)
          .and change(Company, :count).by(1)
          .and change(CompanyMember, :count).by(1)
          .and change(UserCredential, :count).by(1)

        expect(response).to have_http_status(:created)

        # Verify associations
        user_profile = UserProfile.last
        company = Company.last
        tenant = Tenant.last

        expect(company.owned_by).to eq(user_profile)
        # The company belongs to the tenant
        expect(company.tenant).to eq(tenant)
      end

      it 'generates correct company and account codes' do
        post :register, params: valid_params

        expect(Company.last.code).to match(/TEST-COMPANY-[A-Za-z0-9]{6}/)
        expect(Tenant.last.code).to match(/ACC-TRACKC-[A-Za-z0-9]{6}/)
      end
    end

    context 'when creating multiple companies under a single tenant' do
      let(:second_company_params) do
        {
          company: {
            name: 'Second Company',
            company_type: 'business'
          }
        }
      end

      let(:second_admin_params) do
        {
          user_profile: {
            first_name: 'Jane',
            last_name: 'Smith',
            email: 'jane.smith@example.com'
          }
        }
      end

      it 'allows multiple companies under the same tenant' do
        # Create first company with first admin
        post :register, params: valid_params
        expect(response).to have_http_status(:created)
        first_admin = UserProfile.last
        tenant = Tenant.last

        # Create second company with second admin under same tenant
        allow(controller).to receive(:get_subject_from_auth_header).and_return('second-mock-subject')
        second_params = second_admin_params.merge(second_company_params)

        # Ensure we use the same tenant
        allow(Tenant).to receive(:find_by).with(name: "Trackc").and_return(tenant)

        expect {
          post :register, params: second_params
        }.to change(Company, :count).by(1)
          .and change(UserProfile, :count).by(1)

        # Verify both companies belong to the same tenant
        expect(Company.all.map(&:tenant)).to all(eq(tenant))

        # Verify each company has its own admin
        first_company = Company.first
        second_company = Company.last

        expect(first_company.owned_by).to eq(first_admin)
        expect(second_company.owned_by).not_to eq(first_admin)
        expect(second_company.owned_by.email).to eq('jane.smith@example.com')
      end
    end
  end

  describe '#generate_company_code' do
    it 'generates a code with correct format' do
      controller = UserRegistrationsController.new
      code = controller.send(:generate_company_code, 'Test Company Name')

      expect(code).to match(/TEST-COMPANY-NAME-[A-Za-z0-9]{6}/)
    end
  end

  describe '#generate_account_code' do
    it 'generates a code with correct format' do
      controller = UserRegistrationsController.new
      code = controller.send(:generate_account_code, 'Test Account Name')

      expect(code).to match(/ACC-TEST-ACCOUNT-NAME-[A-Za-z0-9]{6}/)
    end
  end
end
