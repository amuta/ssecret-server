require 'rails_helper'
require 'openssl'

class AuthenticableDouble
  include PrivateKeyAuthenticable
  attr_accessor :public_key
end

RSpec.describe PrivateKeyAuthenticable do
  subject { AuthenticableDouble.new }

  let(:string_to_verify) { "POST/api/v1/dataThis is a test body.1672531200" }
  let(:digest) { OpenSSL::Digest::SHA256.new }

  context "with a valid RSA key" do
    let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
    let(:signature) { Base64.strict_encode64(private_key.sign(digest, string_to_verify)) }

    before do
      subject.public_key = Base64.strict_encode64(private_key.public_to_pem)
    end

    it "returns true for a valid signature" do
      expect(subject.verify_signature(string_to_verify, signature)).to be true
    end

    it "returns false for an invalid signature" do
      invalid_signature = Base64.strict_encode64("invalid")
      expect(subject.verify_signature(string_to_verify, invalid_signature)).to be false
    end
  end

  context "with a valid ECDSA key" do
    let(:private_key) { OpenSSL::PKey::EC.generate('prime256v1') }
    let(:signature) { Base64.strict_encode64(private_key.sign(digest, string_to_verify)) }

    before do
      subject.public_key = Base64.strict_encode64(private_key.public_to_pem)
    end

    it "returns true for a valid signature" do
      expect(subject.verify_signature(string_to_verify, signature)).to be true
    end
  end

  context "with invalid data" do
    it "returns false if the public key is blank" do
      subject.public_key = ""
      expect(subject.verify_signature("any", "any")).to be false
    end

    it "returns false if the public key is not valid Base64" do
      subject.public_key = "not-base64"
      expect(subject.verify_signature("any", "any")).to be false
    end

    it "returns false if the public key is not a valid PEM" do
      subject.public_key = Base64.strict_encode64("not-a-pem")
      expect(subject.verify_signature("any", "any")).to be false
    end
  end
end
