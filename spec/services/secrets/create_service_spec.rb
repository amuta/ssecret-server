require 'rails_helper'

RSpec.describe Secrets::CreateService do
  let(:user) { create(:user) }
  let(:secret_name) { 'My Test Secret' }
  let(:dek) { 'encrypted_dek_value' }
  let(:items_attributes) do
    [
      { key: 'API_KEY', content: '12345' }
    ]
  end

  subject(:call_service) do
    described_class.call(
      user: user,
      name: secret_name,
      items_attributes: items_attributes,
      access_grants: [
        { group_id: user.personal_group.id, role: 'admin', encrypted_dek: dek }
      ]
    )
  end

  # Set up the request-specific context that the service now depends on.
  before do
    Current.user = user
    Current.correlation_id = SecureRandom.uuid
  end

  context 'with valid parameters' do
    it 'returns a successful result' do
      result = call_service
      expect(result.success?).to be true
      expect(result.errors).to be_nil
    end

    it 'returns the newly created secret in the payload' do
      result = call_service
      expect(result.payload).to be_an_instance_of(Secret)
      expect(result.payload).to be_persisted
    end

    it 'creates a new Secret record' do
      expect { call_service }.to change(Secret, :count).by(1)
    end

    it 'creates a new SecretAccess record for the user personal group' do
      expect { call_service }.to change(SecretAccess, :count).by(1)

      result = call_service
      secret_access = result.payload.secret_accesses.first
      expect(secret_access.group).to eq(user.personal_group)
      expect(secret_access.role).to eq('admin')
      expect(secret_access.encrypted_dek).to eq(dek)
    end

    it 'creates the associated Item records' do
      expect { call_service }.to change(Item, :count).by(1)
    end

    it 'publishes a secret.created audit event' do
      # We expect the EventPublisher to be called with an instance of our
      # structured event object.
      expect(EventPublisher).to receive(:publish).with(an_instance_of(Audit::SecretCreated))
      call_service
    end

    context "when user is member of the group" do
      let(:group) { create(:group, name: 'Test Group') }

      before do
        create(:group_membership, user: user, group: group, role: :admin)
      end

      it 'creates the secret in the specified group' do
        result = described_class.call(
          user: user,
          name: secret_name,
          items_attributes: items_attributes,
          access_grants: [
            {
              group_id: group.id,
              role: 'admin',
              encrypted_dek: 'encrypted_dek_for_test_group'
            }
          ]
        )

        expect(result.success?).to be true
        expect(result.payload).to be_an_instance_of(Secret)
        expect(result.payload).to be_persisted
      end
    end

      context "when user is not member of group" do
        let(:other_group) { create(:group, name: 'Test Group') }
        it 'returns a failure result' do
          result = described_class.call(
            user: user,
            name: secret_name,
            items_attributes: items_attributes,
            access_grants: [
              {
                group_id: other_group.id,
                role: 'admin',
                encrypted_dek: 'encrypted_dek_for_other_group'
              }
            ]
          )

          expect(result.success?).to be false
          expect(result.errors).to include("Group not found or user do not have access to it.")
        end
      end
    end

  context 'without any items' do
    let(:items_attributes) { nil }

    it 'successfully creates a secret with no items' do
      expect { call_service }.to change(Secret, :count).by(1)
        .and change(SecretAccess, :count).by(1)
        .and change(Item, :count).by(0)

      result = call_service
      expect(result.success?).to be true
      expect(result.payload.items.count).to eq(0)
    end
  end

  context 'with invalid parameters' do
    let(:secret_name) { '' }

    it 'returns a failure result with errors' do
      result = call_service
      expect(result.success?).to be false
      expect(result.payload).to be_nil
      expect(result.errors).to include("Name can't be blank")
    end

    it 'does not create any database records' do
      expect { call_service }.not_to change(Secret, :count)
      expect { call_service }.not_to change(SecretAccess, :count)
      expect { call_service }.not_to change(Item, :count)
    end

    it 'does not publish an audit event' do
      expect(EventPublisher).not_to receive(:publish)
      call_service
    end
  end
end
