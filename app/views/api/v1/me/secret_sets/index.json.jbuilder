json.success true
json.data do
  json.shared_sets @secret_sets do |set|
    json.id set.id
    json.name set.name
    json.created_by set.created_by.username
    json.created_at set.created_at
  end

  json.created_sets @created_secret_sets do |set|
    json.id set.id
    json.name set.name
    json.created_at set.created_at
  end
end
