json.array!(@data) do |datum|
  json.extract! datum, :id, :data
  json.url datum_url(datum, format: :json)
end
