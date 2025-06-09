require 'rails_helper'

RSpec.describe SignatureAuthenticator do
  # Create a single test key pair for all examples
  let(:test_keypair) { OpenSSL::PKey::RSA.new(2048) }
  let(:user) do
    create(:user,
      public_key: test_keypair.public_key.to_pem,
      public_key_hash: Digest::SHA256.hexdigest(test_keypair.public_key.to_pem)
    )
  end

  let(:request) { instance_double("ActionDispatch::Request") }
  let(:headers) { {} }
  let(:path) { "/api/v1/me" }
  let(:method) { "GET" }
  let(:body) { "" }
  let(:timestamp) { Time.now.to_i.to_s }

  # Simulate client-side signature generation
  def client_sign_request(string_to_sign)
    Base64.strict_encode64(
      test_keypair.sign(OpenSSL::Digest::SHA256.new, string_to_sign)
    )
  end

  before do
    allow(request).to receive(:headers).and_return(headers)
    allow(request).to receive(:method).and_return(method)
    allow(request).to receive(:fullpath).and_return(path)
    allow(request).to receive(:raw_post).and_return(body)
  end

  describe '#authenticate' do
    context 'when headers are missing' do
      it 'returns error result' do
        result = described_class.new(request).authenticate
        expect(result).not_to be_success
        expect(result.error_code).to eq(:missing_params)
      end
    end

    context 'when timestamp is expired' do
      let(:expired_timestamp) { 6.minutes.ago.to_i.to_s }

      before do
        # Simulate client signing an expired request
        string_to_sign = "#{method}#{path}#{body}#{expired_timestamp}"
        headers['X-Signature'] = client_sign_request(string_to_sign)
        headers['X-Timestamp'] = expired_timestamp
        headers['X-Key-Hash'] = user.public_key_hash
      end

      it 'returns expired error' do
        result = described_class.new(request).authenticate
        expect(result).not_to be_success
        expect(result.error_code).to eq(:expired)
      end
    end

    context 'with valid signature' do
      before do
        # Simulate client signing a valid request
        string_to_sign = "#{method}#{path}#{body}#{timestamp}"
        headers['X-Signature'] = client_sign_request(string_to_sign)
        headers['X-Timestamp'] = timestamp
        headers['X-Key-Hash'] = user.public_key_hash
      end

      it 'returns success result with user' do
        result = described_class.new(request).authenticate
        expect(result).to be_success
        expect(result.user).to eq(user)
      end
    end
  end
end
