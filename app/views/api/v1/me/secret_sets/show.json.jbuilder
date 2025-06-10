json.success true
json.data do
  json.id         @secret_set.id
  json.name       @secret_set.name
  json.created_by @secret_set.created_by.username
  json.created_at @secret_set.created_at

  json.secrets do
    json.array! @secret_set.secrets do |secret|
      json.id       secret.id
      json.key      secret.key
      json.content  secret.content
      json.metadata secret.metadata
      json.created_at secret.created_at
      json.updated_at secret.updated_at
    end
  end
end
