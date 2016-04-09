module ApplicationHelper
  def avatar_url(user)
  	email = user.email || "guest@insightful.com"
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=36&d=identicon"
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files, 'data-turbolinks-track' => false) }
  end

  def material_icons name
    content_tag(:i, name, class: "material-icons")
  end
end
