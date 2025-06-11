require 'rails_helper'

RSpec.describe SignatureAuthenticator do
  let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:public_key_pem) { private_key.public_to_pem }
  let(:b64_public_key) { Base64.strict_encode64(public_key_pem) }
  let(:public_key_hash) { OpenSSL::Digest::SHA256.hexdigest(public_key_pem) }

  let!(:user) { User.create!(username: 'test', public_key: b64_public_key, public_key_hash: public_key_hash) }

  let(:request) { instance_double(ActionDispatch::Request, headers: headers, method: 'POST', fullpath: '/api/v1/data', raw_post: '{"foo":"bar"}') }
  let(:timestamp) { Time.now.to_i }
  let(:string_to_verify) { "POST/api/v1/data{\"foo\":\"bar\"}#{timestamp}" }
  let(:signature) { Base64.strict_encode64(private_key.sign(OpenSSL::Digest::SHA256.new, string_to_verify)) }

  let(:headers) do
    {
      "X-Signature" => signature,
      "X-Timestamp" => timestamp,
      "X-Key-Hash" => public_key_hash
    }
  end

  subject { described_class.new(request) }

  context "with valid authentication parameters" do
    it "returns a successful result with the correct user" do
      result = subject.authenticate
      expect(result.success?).to be true
      expect(result.user).to eq(user)
      expect(result.error_code).to be_nil
    end
  end

  context "with missing headers" do
    it "returns a :missing_params error if signature is missing" do
      headers["X-Signature"] = nil
      result = subject.authenticate
      expect(result.success?).to be false
      expect(result.error_code).to eq(:missing_params)
    end
  end

  context "with an expired timestamp" do
    it "returns an :expired error" do
      headers["X-Timestamp"] = 6.minutes.ago.to_i
      result = subject.authenticate
      expect(result.success?).to be false
      expect(result.error_code).to eq(:expired)
    end
  end

  context "with invalid authentication data" do
    it "returns an :invalid_auth error if key hash does not match a user" do
      headers["X-Key-Hash"] = "nonexistent"
      result = subject.authenticate
      expect(result.success?).to be false
      expect(result.error_code).to eq(:invalid_auth)
    end

    it "returns an :invalid_auth error if the signature is invalid" do
      headers["X-Signature"] = Base64.strict_encode64("wrong signature")
      result = subject.authenticate
      expect(result.success?).to be false
      expect(result.error_code).to eq(:invalid_auth)
    end
  end
end
