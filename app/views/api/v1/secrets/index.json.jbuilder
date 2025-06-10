json.success true
json.data do
  json.secrets @secrets do |set|
    json.id set.id
    json.name set.name
    # TODO - Add user permission for this secret
  end
end
