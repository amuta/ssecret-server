json.success true
json.data do
  json.secret_sets @secret_sets do |set|
    json.id set.id
    json.name set.name
    json.created_by set.created_by.username
    json.created_at set.created_at
  end
end
