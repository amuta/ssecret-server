require 'rails_helper'

RSpec.describe 'Me::SecretSets API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:secret_set) { create(:secret_set) }
  let(:own_secret_set) { create(:secret_set) }
  let(:headers) { auth_headers(user) }

  before do
    create(:secret_set_access, user: user, secret_set: secret_set)
    create(:secret, secret_set: secret_set, key: 'TEST_KEY', content: 'test content')
    create(:secret, secret_set: own_secret_set, key: 'MY_KEY', content: 'my content')
  end

  describe 'GET /api/v1/me/secret_sets' do
    it 'returns all secret sets the user has access to' do
      get '/api/v1/me/secret_sets', headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      expect(body['data']['secret_sets'].length).to eq(1)
    end
  end

  describe 'GET /api/v1/me/secret_sets/:id' do
    it 'returns a specific secret set the user has access to' do
      get "/api/v1/me/secret_sets/#{secret_set.id}", headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      expect(body['data']['secret_set']['id']).to eq(secret_set.id)
      expect(body['data']['secret_set']['secrets'].length).to eq(1)
      expect(body['data']['secret_set']['secrets'].first['key']).to eq('TEST_KEY')
      expect(body['data']['secret_set']['secrets'].first['content']).to eq('test content')
    end

    it 'returns 404 if the user does not have access to the secret set' do
      get "/api/v1/me/secret_sets/#{own_secret_set.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      body = response.parsed_body
      expect(body['success']).to be false
    end
  end
end
