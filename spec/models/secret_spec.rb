require 'rails_helper'

RSpec.describe Secret, type: :model do
  describe '#access_context_for' do
    let(:secret) { create(:secret) }
    let(:user) { create(:user) }
    let(:no_access_user) { create(:user) }

    context 'when the user has no access' do
      it 'returns nil' do
        expect(secret.access_context_for(no_access_user)).to be_nil
      end
    end

    context 'when the user has direct access via a personal group' do
      before do
        create(
          :secret_access,
          secret: secret,
          group: user.personal_group,
          role: :admin,
          encrypted_dek: 'dek_for_personal_group'
        )
      end

      it 'returns the correct context with one access path' do
        context = secret.access_context_for(user)
        expect(context).not_to be_nil
        expect(context[:effective_role]).to eq('admin')
        expect(context[:access_paths].size).to eq(1)

        path = context[:access_paths].first
        expect(path[:via_group][:personal]).to be true
        expect(path[:role]).to eq('admin')
        expect(path[:key_chain][:encrypted_dek]).to eq('dek_for_personal_group')
      end
    end

    context 'when the user has access via a shared group' do
      let(:shared_group) { create(:group, name: 'developers') }
      let!(:membership) do
        create(
          :group_membership,
          user: user,
          group: shared_group,
          encrypted_group_key: 'group_key_for_devs'
        )
      end

      before do
        create(
          :secret_access,
          secret: secret,
          group: shared_group,
          role: :write,
          encrypted_dek: 'dek_for_dev_group'
        )
      end

      it 'returns the correct context with one access path' do
        context = secret.access_context_for(user)
        expect(context).not_to be_nil
        expect(context[:effective_role]).to eq('write')
        expect(context[:access_paths].size).to eq(1)

        path = context[:access_paths].first
        expect(path[:via_group][:name]).to eq('developers')
        expect(path[:via_group][:personal]).to be false
        expect(path[:role]).to eq('write')
        expect(path[:key_chain][:encrypted_dek]).to eq('dek_for_dev_group')
        expect(path[:key_chain][:encrypted_group_key]).to eq('group_key_for_devs')
      end
    end

    context 'when the user has multiple access paths with different role' do
      let(:shared_group) { create(:group, name: 'readers') }

      before do
        # Direct access (admin)
        create(
          :secret_access,
          secret: secret,
          group: user.personal_group,
          role: :admin
        )

        # Shared group access (read)
        create(:group_membership, user: user, group: shared_group)
        create(
          :secret_access,
          secret: secret,
          group: shared_group,
          role: :read
        )
      end

      it 'returns the highest effective role' do
        context = secret.access_context_for(user)
        expect(context[:effective_role]).to eq('admin')
      end

      it 'returns details for both access paths' do
        context = secret.access_context_for(user)
        expect(context[:access_paths].size).to eq(2)
        role = context[:access_paths].map { |p| p[:role] }
        expect(role).to contain_exactly('admin', 'read')
      end
    end
  end
end
