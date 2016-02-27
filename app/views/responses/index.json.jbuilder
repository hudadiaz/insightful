json.array!(@responses) do |response|
  json.extract! response, :id, :user_id, :survey_id, :question_id, :option_id
  json.url response_url(response, format: :json)
end
