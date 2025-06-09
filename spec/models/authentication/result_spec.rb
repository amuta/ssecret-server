require 'rails_helper'

RSpec.describe Authentication::Result do
  let(:user) { create(:user) }

  describe '#success?' do
    it 'returns true when user is present' do
      result = described_class.new(user: user)
      expect(result).to be_success
    end

    it 'returns false when user is nil' do
      result = described_class.new(error_code: :invalid_auth)
      expect(result).not_to be_success
    end
  end

  describe '#as_json' do
    context 'when successful' do
      it 'returns success json' do
        result = described_class.new(user: user)
        expect(result.as_json).to eq({ success: true })
      end
    end

    context 'when failed' do
      it 'returns error json' do
        result = described_class.new(error_code: :expired)
        expect(result.as_json).to eq({
          success: false,
          error: "Request has expired"
        })
      end
    end
  end
end
