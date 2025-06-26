require 'rails_helper'

RSpec.describe 'Me API', type: :request do
  let(:user) { create(:user) }
  let(:endpoint) { '/api/v1/me' }

  describe 'GET /api/v1/me' do
    context 'with JWT authentication' do
      it 'returns user information' do
        token = user.generate_jwt
        get endpoint, headers: { 'Authorization': "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include(
          "success" => true,
          "data" => {
            "username"=> user.username,
            "member_of"=>[
              {
                "encrypted_group_key"=> user.personal_group.key_for_user(user),
                "id"=> user.personal_group.id,
                "is_personal"=>true,
                "name"=>user.personal_group.name
              }
            ]
            }
        )
      end
    end

    context 'with signature authentication' do
      it 'returns user information' do
        timestamp = Time.now.to_i
        headers = sign_request(user: user, endpoint: endpoint, method: 'GET', timestamp: timestamp)

        get endpoint, headers: headers

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include(
                "success" => true,
                "data" => {
                  "username"=> user.username,
                  "member_of"=>[
                    {
                      "encrypted_group_key"=> user.personal_group.key_for_user(user),
                      "id"=> user.personal_group.id,
                      "is_personal"=>true,
                      "name"=>user.personal_group.name
                    }
                  ]
                  }
              )
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get endpoint
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
