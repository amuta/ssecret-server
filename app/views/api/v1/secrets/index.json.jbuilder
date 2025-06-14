json.data do
  json.secrets @secrets do |secret|
    json.id secret.id
    json.name secret.name

    # Get the complete access context for the current user.
    context = secret.access_context_for(@current_user)

    if context
      json.effective_role context[:effective_role]
      json.access_paths context[:access_paths]
    end

    # Also include the secret's items.
    json.items secret.items, :id, :key, :content, :metadata
  end
end
