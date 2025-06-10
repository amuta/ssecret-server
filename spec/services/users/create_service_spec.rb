require 'rails_helper'

RSpec.describe Users::CreateService, type: :service do
  let(:rsa_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:pem_public_key) { rsa_key.public_key.to_pem }
  let(:valid_attributes) do
    {
      username: 'testuser',
      raw_public_key: pem_public_key,
      admin: true
    }
  end
  let(:params) { valid_attributes }

  subject { described_class.call(**params) }

  describe ".call" do
    context "with valid attributes" do
      it "creates a new user" do
        expect { subject }
          .to change(User, :count).by(1)
      end

      it "returns a successful result with the user payload" do
        result = subject

        expect(result).to be_success
        expect(result.payload).to be_a(User)
        expect(result.payload.username).to eq('testuser')
      end
    end

    context "with invalid attributes" do
      let(:params) { valid_attributes.merge(username: '') }

      it "does not create a new user" do
        expect { subject }
          .not_to change(User, :count)
      end

      it "returns a failure result with error messages" do
        result = subject

        expect(result).not_to be_success
        expect(result.payload).to be_nil
        expect(result.errors).to include("Username can't be blank")
      end
    end
  end
end
