json.success true
json.data do
  json.secret do
    json.id         @secret.id
    json.name       @secret.name

    context = @secret.access_context_for(@current_user)

    json.effective_role context[:effective_role]
    json.encrypted_dek context[:access_paths].first.dig(:key_chain, :encrypted_dek)
    json.encrypted_group_key context[:access_paths].first.dig(:key_chain, :encrypted_group_key)

    json.items do
      json.array! @secret.items do |secret|
        json.id       secret.id
        json.key      secret.key
        json.content  secret.content
        json.metadata secret.metadata
      end
    end
  end
end
