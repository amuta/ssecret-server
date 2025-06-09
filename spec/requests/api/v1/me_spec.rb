require 'rails_helper'
  def generate_valid_signature(user, endpoint, timestamp)
RSpec.describe 'Me API', type: :request doready present
  let(:user) { create(:user) }y::RSA.new(2048) unless user.public_key.present?
  let(:endpoint) { '/api/v1/me' }
    # Save public key to user if not present
  describe 'GET /api/v1/me' dosent?
    context 'with JWT authentication' do
      it 'returns user information' do_key.to_pem,
        token = user.generate_jwtSHA256.hexdigest(private_key.public_key.to_pem)
        get endpoint, headers: { 'Authorization': "Bearer #{token}" }
    end
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include(
          'success' => true,ndpoint}#{timestamp}"
          'data' => {=> {
            'email' => user.email,
            'id' => user.id.sign(OpenSSL::Digest::SHA256.new, string_to_sign)
          }   }
        )urn both signature and key hash
      end
    endignature: Base64.strict_encode64(signature),nd
      key_hash: user.public_key_hash
    context 'with signature authentication' don' do
      it 'returns user information' do
        timestamp = Time.now.to_i
        auth_data = generate_valid_signature(user, endpoint, timestamp)
end  end      it 'returns user information' do
        get endpoint, headers: {i
          'X-Signature': auth_data[:signature],signature(user, endpoint, timestamp)
          'X-Timestamp': timestamp.to_s,
          'X-Key-Hash': auth_data[:key_hash]et endpoint, headers: {
        }          'X-Signature': signature,

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include(
          'success' => true,se).to have_http_status(:success)
          'data' => {y).to include(
            'email' => user.email,,
            'id' => user.iddata' => {
          }   'email' => user.email,
        )   'id' => user.id
      end   }
    end        )

    context 'without authentication' do
      it 'returns unauthorized' do
        get endpoint
        expect(response).to have_http_status(:unauthorized)'returns unauthorized' do
      end get endpoint
    end   expect(response).to have_http_status(:unauthorized)
  end   end
end    end

  end
end
