json.array!(@surveys) do |survey|
  json.extract! survey, :id, :title, :description, :user_id, :public, :require_login, :answer_is_editable
  json.url survey_url(survey, format: :json)
end
