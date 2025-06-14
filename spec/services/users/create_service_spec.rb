require 'rails_helper'

RSpec.describe Users::CreateService, type: :service do
  let(:rsa_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:pem_public_key) { rsa_key.public_key.to_pem }
  let(:valid_attributes) do
    {
      username: 'testuser',
      raw_public_key: pem_public_key,
      personal_group_encrypted_key: 'encrypted_key_value'
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

      it "creates a personal group and groupmembership with the groupkey" do
        expect { subject }
          .to change(Group, :count).by(1)
          .and change(GroupMembership, :count).by(1)

        result = subject
        user = result.payload
        personal_group = user.personal_group

        expect(personal_group.name).to eq('testuser-personal')
        expect(personal_group.group_memberships.first.role).to eq('admin')
        expect(personal_group.group_memberships.first.encrypted_group_key).to eq('encrypted_key_value')
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
