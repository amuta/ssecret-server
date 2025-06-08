require 'rails_helper'

RSpec.describe 'Api::Auth', type: :request do
  describe 'POST /api/login' do
    let!(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'secure_password') }
    let(:login_params) do
      {
        user: {
          email: 'test@example.com',
          password: 'secure_password'
        }
      }
    end
    let(:invalid_login_params) do
      { user:
        {
          email: 'test@example.com',
          password: 'wrong_password'
        }
      }
    end

    context 'with valid credentials' do
      before do
        post '/api/login', params: login_params
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a token in the response body' do
        expect(response.parsed_body).to include('token')
      end

      it 'returns a non-empty token' do
        expect(response.parsed_body['token']).not_to be_empty
      end
    end

    context 'with invalid credentials' do
      before do
        post '/api/login', params: invalid_login_params
      end

      it 'returns http unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        expect(response.parsed_body).to include('error' => 'Invalid email or password')
      end
    end
  end
end
