require 'rails_helper'

RSpec.describe 'Secrets API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:secret) { create(:secret) }
  let(:own_secret) { create(:secret) }
  let(:headers) { auth_headers(user) }

  before do
    create(:secret_access, user: user, secret: secret)
    create(:item, secret: secret, key: 'TEST_KEY', content: 'test content')
    create(:item, secret: own_secret, key: 'MY_KEY', content: 'my content')
  end

  describe 'GET /api/v1/secrets' do
    it 'returns all secret the user has access to' do
      get '/api/v1/secrets', headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      expect(body['data']['secrets'].length).to eq(1)
    end
  end

  describe 'GET /api/v1/secrets/:id' do
    it 'returns a specific secret set the user has access to' do
      get "/api/v1/secrets/#{secret.id}", headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      expect(body['data']['secret']['id']).to eq(secret.id)
      expect(body['data']['secret']['items'].length).to eq(1)
      expect(body['data']['secret']['items'].first['key']).to eq('TEST_KEY')
      expect(body['data']['secret']['items'].first['content']).to eq('test content')
    end

    it 'returns 404 if the user does not have access to the secret set' do
      get "/api/v1/secrets/#{own_secret.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      body = response.parsed_body
      expect(body['success']).to be false
    end
  end

  describe 'POST /api/v1/secrets' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          secret: {
            name: 'NewSecret',
            dek_encrypted: 'encrypted_dak_value'
          }
        }
      end

      it 'creates a new secret and returns it' do
        expect {
          post '/api/v1/secrets', params: valid_params, headers: headers
        }.to change(Secret, :count).by(1)

        expect(response).to have_http_status(:created)
        body = response.parsed_body
        expect(body['success']).to be true
        expect(body['data']['secret']['name']).to eq('NewSecret')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        post '/api/v1/secrets',
             params: { secret: { name: '' } },
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        body = response.parsed_body
        expect(body['success']).to be false
      end
    end
  end

  describe 'DELETE /api/v1/secrets/:id' do
    let!(:owned_secret) { create(:secret) }

    before do
      create(
        :secret_access,
        user: user,
        secret: owned_secret,
        permissions: :admin
      )
    end

    it 'deletes a secret the user manages' do
      expect {
        delete "/api/v1/secrets/#{owned_secret.id}", headers: headers
      }.to change(Secret, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns not_found if the user cannot manage the secret' do
      other_secret = create(:secret)
      create(
        :secret_access,
        user: other_user,
        secret: other_secret,
        permissions: :admin
      )

      delete "/api/v1/secrets/#{other_secret.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      body = response.parsed_body
      expect(body['error']).to eq('Resource Not Found')
      expect(body['success']).to be false
    end
  end
end
