require 'rails_helper'

RSpec.describe 'Me::SecretSets API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:secret_set) { create(:secret_set, created_by: other_user) }
  let(:own_secret_set) { create(:secret_set, created_by: user) }
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
end
