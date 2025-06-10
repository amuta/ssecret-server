json.success true
json.data do
  json.secret_sets @secret_sets do |set|
    json.id set.id
    json.name set.name
  end
end
