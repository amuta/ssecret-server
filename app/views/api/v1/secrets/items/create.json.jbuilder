json.success true
json.data do
  json.extract! @item, :id, :key, :content, :metadata, :created_at, :updated_at
end
