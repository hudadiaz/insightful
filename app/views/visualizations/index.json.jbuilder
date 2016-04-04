json.array!(@visualizations) do |visualization|
  json.extract! visualization, :id, :title, :caption, :type, :selections, :datum_id
  json.url visualization_url(visualization, format: :json)
end
