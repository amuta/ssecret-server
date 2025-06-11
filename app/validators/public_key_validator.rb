class PublicKeyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    result = PubkeyNormalizer.normalize(value)

    if result.success?
      record.public_key = result.b64_key
      record.public_key_hash = result.hash
    else
      record.errors.add(attribute, result.error || "is not a valid or supported public key format")
    end
  end
end
