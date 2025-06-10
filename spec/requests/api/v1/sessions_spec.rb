require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  describe 'POST /api/v1/sessions' do
    let(:user) { create(:user, password: 'password123') }
    let(:endpoint) { '/api/v1/sessions' }

    context 'with valid credentials' do
      it 'returns JWT token' do
        post endpoint, params: {
          user: {
            username: user.username,
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized' do
        post endpoint, params: {
          user: {
            username: user.username,
            password: 'wrong_password'
          }
        }

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Invalid username or password')
      end
    end

    context 'with user without password' do
      let(:user_without_password) { create(:user, password: nil) }

      it 'returns unauthorized when attempting login' do
        post endpoint, params: {
          user: {
            username: user_without_password.username,
            password: ''
          }
        }

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Invalid username or password')
      end
    end
  end

  describe 'authentication methods' do
    let(:protected_endpoint) { '/api/v1/me' }
    let(:user) { create(:user) }

    context 'with JWT authentication' do
      it 'authenticates successfully with valid token' do
        token = user.generate_jwt
        get protected_endpoint, headers: { 'Authorization': "Bearer #{token}" }
        expect(response).to have_http_status(:success)
        expect(response.parsed_body['success']).to be true
      end

      it 'fails with invalid token' do
        get protected_endpoint, headers: { 'Authorization': "Bearer invalid" }
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Authentication failed')
      end
    end

    context 'with signature authentication' do
      it 'authenticates successfully with valid signature' do
        timestamp = Time.now.to_i
        headers = sign_request(user: user, endpoint: protected_endpoint, timestamp: timestamp)

        get protected_endpoint, headers: headers
        expect(response).to have_http_status(:success)
        expect(response.parsed_body['success']).to be true
      end

      it 'fails with expired timestamp' do
        timestamp = 6.minutes.ago.to_i
        headers = sign_request(user: user, endpoint: protected_endpoint, timestamp: timestamp)

        get protected_endpoint, headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Request has expired')
      end
    end
  end
end
