json.success true
json.data do
  json.secret do
    json.id         @secret.id
    json.name       @secret.name

    json.items do
      json.array! @secret.items do |item|
        json.id       item.id
        json.key      item.key
      end
    end
  end
end
