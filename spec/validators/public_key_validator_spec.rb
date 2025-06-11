require 'rails_helper'

class Validatable
  include ActiveModel::Validations
  attr_accessor :raw_public_key, :public_key, :public_key_hash
  validates :raw_public_key, public_key: true, allow_blank: true
end

RSpec.describe PublicKeyValidator do
  subject { Validatable.new }

  context 'with a valid PEM public key' do
    let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
    let(:public_key_pem) { private_key.public_to_pem }

    it 'is valid and sets the derived attributes' do
      subject.raw_public_key = public_key_pem
      expect(subject).to be_valid
      expect(subject.public_key).not_to be_nil
      expect(subject.public_key_hash).to match(/^[a-f0-9]{64}$/)
    end
  end

  context 'with a valid OpenSSH public key' do
    let(:private_key) { OpenSSL::PKey::EC.generate('prime256v1') }
    let(:openssh_key) { "ecdsa-sha2-nistp256 #{Base64.strict_encode64(private_key.public_key.to_blob)}" }

    it 'is valid and sets the derived attributes' do
      subject.raw_public_key = openssh_key
      expect(subject).to be_valid
      expect(subject.public_key).not_to be_nil
      expect(subject.public_key_hash).to match(/^[a-f0-9]{64}$/)
    end
  end

  context 'with an invalid key' do
    it 'is invalid and adds an error' do
      subject.raw_public_key = 'this is not a valid key'
      expect(subject).not_to be_valid
      expect(subject.errors[:raw_public_key]).to include("Unsupported or invalid key format.")
    end
  end

  context 'with a blank key' do
    it 'is valid and does not add an error' do
      subject.raw_public_key = ''
      expect(subject).to be_valid
      expect(subject.errors[:raw_public_key]).to be_empty
    end
  end
end
