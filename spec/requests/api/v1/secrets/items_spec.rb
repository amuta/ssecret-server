require 'rails_helper'

RSpec.describe 'Secret Items API', type: :request do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }
  let(:secret)     { create(:secret) }
  let(:headers)    { auth_headers(user) }

  before do
    # grant default (read) access
    create(:secret_access, user: user, secret: secret, permissions: :read)
    # seed two items
    create(:item, secret: secret, key: 'K1', content: 'C1', metadata: { a: 1 })
    create(:item, secret: secret, key: 'K2', content: 'C2', metadata: { b: 2 })
  end

  describe 'GET /api/v1/secrets/:secret_id/items/:id' do
    let(:item) { secret.items.first }

    it 'returns the specified item' do
      get "/api/v1/secrets/#{secret.id}/items/#{item.id}", headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      data = body['data']
      expect(data['id']).to eq(item.id)
      expect(data['key']).to eq('K1')
      expect(data['content']).to eq('C1')
      expect(data['metadata']).to eq('a' => 1)
    end

    it 'returns not_found for an invalid item id' do
      get "/api/v1/secrets/#{secret.id}/items/9999", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body['success']).to be false
    end
  end

  describe 'POST /api/v1/secrets/:secret_id/items' do
    let(:valid_params) { { item: { key: 'NEW', content: 'VAL', metadata: { x: 9 } } } }

    context 'with write permission' do
      before do
        # upgrade to write
        secret.secret_accesses.find_by(user: user).update!(permissions: :write)
      end

      it 'creates a new item' do
        expect {
          post "/api/v1/secrets/#{secret.id}/items", params: valid_params, headers: headers
        }.to change(Item, :count).by(1)
        expect(response).to have_http_status(:created)
        body = response.parsed_body
        expect(body['success']).to be true
      end
    end

    context 'with read-only permission' do
      it 'returns unauthorize (no write rights)' do
        post "/api/v1/secrets/#{secret.id}/items", params: valid_params, headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['success']).to be false
      end
    end
  end

  describe 'PATCH /api/v1/secrets/:secret_id/items/:id' do
    let!(:item) { secret.items.first }
    let(:update_params) { { item: { content: 'UPDATED' } } }

    context 'with write permission' do
      before do
        secret.secret_accesses.find_by(user: user).update!(permissions: :write)
      end

      it 'updates the item' do
        patch "/api/v1/secrets/#{secret.id}/items/#{item.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:no_content)
        expect(item.reload.content).to eq('UPDATED')
      end
    end

    context 'with read-only permission' do
      it 'returns unauthorized (no write rights)' do
        patch "/api/v1/secrets/#{secret.id}/items/#{item.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/secrets/:secret_id/items/:id' do
    let!(:item) { secret.items.first }

    context 'with write permission' do
      before do
        secret.secret_accesses.find_by(user: user).update!(permissions: :write)
      end

      it 'deletes the item' do
        expect {
          delete "/api/v1/secrets/#{secret.id}/items/#{item.id}", headers: headers
        }.to change(Item, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with read-only permission' do
      it 'returns unauthorized (no write rights)' do
        delete "/api/v1/secrets/#{secret.id}/items/#{item.id}", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
# filepath: spec/requests/api/v1/secrets/items_spec.rb
require 'rails_helper'

RSpec.describe 'Secret Items API', type: :request do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }
  let(:secret)     { create(:secret) }
  let(:headers)    { auth_headers(user) }

  before do
    # grant default (read) access
    create(:secret_access, user: user, secret: secret, permissions: :read)
    # seed two items
    create(:item, secret: secret, key: 'K1', content: 'C1', metadata: { a: 1 })
    create(:item, secret: secret, key: 'K2', content: 'C2', metadata: { b: 2 })
  end

  describe 'GET /api/v1/secrets/:secret_id/items/:id' do
    let(:item) { secret.items.first }

    it 'returns the specified item' do
      get "/api/v1/secrets/#{secret.id}/items/#{item.id}", headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['success']).to be true
      data = body['data']
      expect(data['id']).to eq(item.id)
      expect(data['key']).to eq('K1')
      expect(data['content']).to eq('C1')
      expect(data['metadata']).to eq('a' => 1)
    end

    it 'returns not_found for an invalid item id' do
      get "/api/v1/secrets/#{secret.id}/items/9999", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body['success']).to be false
    end
  end

  describe 'POST /api/v1/secrets/:secret_id/items' do
    let(:valid_params) { { item: { key: 'NEW', content: 'VAL', metadata: { x: 9 } } } }

    context 'with write permission' do
      before do
        # upgrade to write
        secret.secret_accesses.find_by(user: user).update!(permissions: :write)
      end

      it 'creates a new item' do
        expect {
          post "/api/v1/secrets/#{secret.id}/items", params: valid_params, headers: headers
        }.to change(Item, :count).by(1)
        expect(response).to have_http_status(:created)
        body = response.parsed_body
        expect(body['success']).to be true
      end
    end

    context 'with read-only permission' do
      it 'returns unauthorized (no write rights)' do
        post "/api/v1/secrets/#{secret.id}/items", params: valid_params, headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['success']).to be false
      end
    end
  end

  describe 'PATCH /api/v1/secrets/:secret_id/items/:id' do
    let!(:item) { secret.items.first }
    let(:update_params) { { item: { content: 'UPDATED' } } }

    context 'with write permission' do
      before do
        secret.secret_accesses.find_by(user: user).update!(permissions: :write)
      end

      it 'updates the item' do
        patch "/api/v1/secrets/#{secret.id}/items/#{item.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:no_content)
        expect(item.reload.content).to eq('UPDATED')
      end
    end

    context 'with read-only permission' do
      it 'returns unauthorized (no write rights)' do
        patch "/api/v1/secrets/#{secret.id}/items/#{item.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/secrets/:secret_id/items/:id' do
    let!(:item) { secret.items.first }

    context 'with write permission' do
      before do
        secret.secret_accesses.find_by(user: user).update!(permissions: :write)
      end

      it 'deletes the item' do
        expect {
          delete "/api/v1/secrets/#{secret.id}/items/#{item.id}", headers: headers
        }.to change(Item, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with read-only permission' do
      it 'returns unauthorized (no delete rights)' do
        delete "/api/v1/secrets/#{secret.id}/items/#{item.id}", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
