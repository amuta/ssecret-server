json.success true
json.data do
  json.secret do
    json.id         @secret.id
    json.name       @secret.name
    json.dek_encrypted @secret.dek_for(@current_user)
    json.permission @secret.permissions_for(@current_user)

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
