json.success true
json.data do
  json.secrets @secrets do |set|
    json.id set.id
    json.name set.name
  end
end
