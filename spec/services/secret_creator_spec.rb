require 'rails_helper'

RSpec.describe SecretCreator do
  let(:user) { User.create!(username: 'testuser') }
  let(:secret_name) { 'My Test Secret' }
  let(:dek) { 'encrypted_dek_value' }
  let(:items_attributes) do
    [
      { key: 'API_KEY', content: '12345' },
      { key: 'PASSWORD', content: 'abcde' }
    ]
  end

  subject do
    described_class.call(
      user: user,
      name: secret_name,
      dek: dek,
      items_attributes: items_attributes
    )
  end

  context 'with valid parameters' do
    it 'returns a successful result' do
      result = subject
      expect(result.success?).to be true
      expect(result.errors).to be_nil
    end

    it 'returns the newly created secret in the payload' do
      result = subject
      expect(result.payload).to be_an_instance_of(Secret)
      expect(result.payload).to be_persisted
    end

    it 'creates a new Secret record' do
      expect { subject }.to change(Secret, :count).by(1)
    end

    it 'creates a new SecretAccess record for the user' do
      expect { subject }.to change(SecretAccess, :count).by(1)
      secret_access = Secret.last.secret_accesses.last
      expect(secret_access.user).to eq(user)
      expect(secret_access.permissions).to eq('admin')
      expect(secret_access.dek_encrypted).to eq(dek)
    end

    it 'creates the associated Item records' do
      expect { subject }.to change(Item, :count).by(2)
      secret = Secret.last
      expect(secret.items.count).to eq(2)
      expect(secret.items.first.key).to eq('API_KEY')
    end
  end

  context 'without any items' do
    let(:items_attributes) { nil }

    it 'successfully creates a secret with no items' do
      expect { subject }.to change(Secret, :count).by(1)
        .and change(SecretAccess, :count).by(1)
        .and change(Item, :count).by(0)

      result = subject
      expect(result.success?).to be true
      expect(result.payload.items.count).to eq(0)
    end
  end

  context 'with invalid parameters' do
    let(:secret_name) { '' }

    it 'returns a failure result' do
      result = subject
      expect(result.success?).to be false
      expect(result.payload).to be_nil
    end

    it 'returns validation errors' do
      result = subject
      expect(result.errors).to include("Name can't be blank")
    end

    it 'does not create a Secret' do
      expect { subject }.not_to change(Secret, :count)
    end

    it 'does not create a SecretAccess' do
      expect { subject }.not_to change(SecretAccess, :count)
    end

    it 'does not create any Items' do
      expect { subject }.not_to change(Item, :count)
    end
  end
end
