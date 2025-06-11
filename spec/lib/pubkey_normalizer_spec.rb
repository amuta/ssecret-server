require_relative '../../lib/pubkey_normalizer'

RSpec.describe PubkeyNormalizer do
  describe '.normalize' do
    context 'with RSA keys' do
      it 'produces the same result for different formats of the same RSA key' do
        private_key = OpenSSL::PKey::RSA.new(2048)
        public_key_obj = private_key.public_key

        pem_format = public_key_obj.to_pem
        legacy_pem_format = private_key.public_to_pem
        openssh_format = "ssh-rsa #{Base64.strict_encode64(public_key_obj.to_blob)}"

        result1 = PubkeyNormalizer.normalize(pem_format)
        result2 = PubkeyNormalizer.normalize(legacy_pem_format)
        result3 = PubkeyNormalizer.normalize(openssh_format)

        expect(result1.success?).to be true
        expect(result2.success?).to be true
        expect(result3.success?).to be true

        expect(result1.hash).to eq(result2.hash)
        expect(result2.hash).to eq(result3.hash)
        expect(result1.b64_key).to eq(result2.b64_key)
      end
    end

    context 'with ECDSA keys' do
      it 'produces the same result for different formats of the same ECDSA key' do
        private_key = OpenSSL::PKey::EC.generate('prime256v1')
        public_key_pem = private_key.public_to_pem
        public_blob = private_key.public_key.to_blob
        encoded_pubkey = Base64.strict_encode64(public_blob)

        openssh_format = "ecdsa-sha2-nistp256 #{encoded_pubkey}}"

        Net::SSH::KeyFactory.load_data_public_key(openssh_format)

        result1 = PubkeyNormalizer.normalize(public_key_pem)
        result2 = PubkeyNormalizer.normalize(openssh_format)

        expect(result1.success?).to be true
        expect(result2.success?).to be true
        expect(result1.hash).to eq(result2.hash)
        expect(result1.b64_key).to eq(result2.b64_key)
      end
    end

    it 'handles private keys by extracting the public part' do
      private_key = OpenSSL::PKey::RSA.new(2048)
      public_key_pem = private_key.public_key.to_pem

      result = PubkeyNormalizer.normalize(private_key.to_pem)

      expect(result.success?).to be true
      decoded_pem = Base64.strict_decode64(result.b64_key)
      expect(decoded_pem).to eq(public_key_pem)
    end

    it 'returns a failure result for invalid key strings' do
      result = PubkeyNormalizer.normalize("this is definitely not a key")

      expect(result.success?).to be false
      expect(result.b64_key).to be_nil
      expect(result.hash).to be_nil
      expect(result.error).to eq("Unsupported or invalid key format.")
    end
  end
end
