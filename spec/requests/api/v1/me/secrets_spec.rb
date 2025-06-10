require 'rails_helper'

RSpec.describe 'Me::Secrets API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:secret) { create(:secret) }
  let(:own_secret) { create(:secret) }
  let(:headers) { auth_headers(user) }

  before do
    create(:secret_set_access, user: user, secret: secret)
    create(:item, secret: secret, key: 'TEST_KEY', content: 'test content')
    create(:item, secret: own_secret, key: 'MY_KEY', content: 'my content')
  end

  describe 'GET /api/v1/me/secrets' do
    it 'returns all secret the user has access to' do
      get '/api/v1/me/secrets', headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      expect(body['data']['secrets'].length).to eq(1)
    end
  end

  describe 'GET /api/v1/me/secrets/:id' do
    it 'returns a specific secret set the user has access to' do
      get "/api/v1/me/secrets/#{secret.id}", headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      expect(body['data']['secret']['id']).to eq(secret.id)
      expect(body['data']['secret']['items'].length).to eq(1)
      expect(body['data']['secret']['items'].first['key']).to eq('TEST_KEY')
      expect(body['data']['secret']['items'].first['content']).to eq('test content')
    end

    it 'returns 404 if the user does not have access to the secret set' do
      get "/api/v1/me/secrets/#{own_secret.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      body = response.parsed_body
      expect(body['success']).to be false
    end
  end
end
