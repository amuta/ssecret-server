json.success true
json.data do
  json.secret_set do
    json.id         @secret_set.id
    json.name       @secret_set.name
    json.dek_encrypted @user_access.dek_encrypted


    json.items do
      json.array! @secret_set.items do |secret|
        json.id       secret.id
        json.key      secret.key
        json.content  secret.content
        json.metadata secret.metadata
      end
    end
  end
end
