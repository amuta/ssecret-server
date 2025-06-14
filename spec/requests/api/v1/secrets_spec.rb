require 'rails_helper'

RSpec.describe 'Secrets API', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:secret) { create(:secret) }
  let!(:headers) { auth_headers(user) }
  let!(:other_headers) { auth_headers(other_user) }

  describe 'GET /api/v1/secrets' do
    context 'when user has direct and indirect access' do
      let!(:shared_group) { create(:group, name: 'developers') }

      before do
        # Grant user 'admin' access via their personal group
        create(:secret_access,
               secret: secret,
               group: user.personal_group,
               role: :admin,
               encrypted_dek: 'personal_dek')

        # Grant user 'read' access via a shared group
        create(:group_membership, user: user, group: shared_group, encrypted_group_key: 'user_group_key')
        create(:secret_access,
               secret: secret,
               group: shared_group,
               role: :read,
               encrypted_dek: 'shared_dek')
      end

      it 'returns the secret with the highest effective role' do
        get '/api/v1/secrets', headers: headers
        expect(response).to have_http_status(:success)

        body = response.parsed_body['data']
        expect(body['secrets'].length).to eq(1)

        secret_data = body['secrets'].first
        expect(secret_data['effective_role']).to eq('admin')
      end

      it 'returns all access paths with correct key chains' do
        get '/api/v1/secrets', headers: headers
        secret_data = response.parsed_body.dig('data', 'secrets', 0)

        expect(secret_data['access_paths'].length).to eq(2)

        personal_path = secret_data['access_paths'].find { |p| p['via_group']['personal'] == true }
        shared_path = secret_data['access_paths'].find { |p| p['via_group']['personal'] == false }

        expect(personal_path['role']).to eq('admin')
        expect(personal_path['key_chain']['encrypted_dek']).to eq('personal_dek')

        expect(shared_path['role']).to eq('read')
        expect(shared_path['key_chain']['encrypted_dek']).to eq('shared_dek')
        expect(shared_path['key_chain']['encrypted_group_key']).to eq('user_group_key')
      end
    end

    context 'when user has no access' do
      it 'returns an empty array of secrets' do
        get '/api/v1/secrets', headers: headers
        expect(response).to have_http_status(:success)
        body = response.parsed_body['data']
        expect(body['secrets']).to be_empty
      end
    end
  end

  describe 'POST /api/v1/secrets' do
    let(:valid_params) do
      {
        secret: {
          name: 'New App Secret',
          encrypted_dek: 'encrypted_value_for_creator'
        }
      }
    end

    it 'creates a new secret' do
      expect {
        post '/api/v1/secrets', params: valid_params, headers: headers
      }.to change(Secret, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'grants the creating user admin access via their personal group' do
      post '/api/v1/secrets', params: valid_params, headers: headers

      new_secret = Secret.last
      secret_access = new_secret.secret_accesses.first

      expect(secret_access.group).to eq(user.personal_group)
      expect(secret_access).to be_admin
      expect(secret_access.encrypted_dek).to eq('encrypted_value_for_creator')
    end
  end

  describe 'DELETE /api/v1/secrets/:id' do
    let!(:secret_to_delete) { create(:secret) }

    context 'when user has admin role' do
      before do
        create(:secret_access, secret: secret_to_delete, group: user.personal_group, role: :admin)
      end

      it 'deletes the secret' do
        expect {
          delete "/api/v1/secrets/#{secret_to_delete.id}", headers: headers
        }.to change(Secret, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user does not have admin role' do
      before do
        create(:secret_access, secret: secret_to_delete, group: other_user.personal_group, role: :write)
      end

      it 'returns unauthorized' do
        delete "/api/v1/secrets/#{secret_to_delete.id}", headers: other_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
