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

  def alert content, type
    unless content.nil? || content.blank? || content.empty?
      type = type || 'info'
      content_tag :div, class: 'alert alert-dismissible alert-'+type do
        content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' }) +
        content
      end
    end
  end

  def pageviews path
    pageviews_since path, 1.month.ago
  end

  def pageviews_since path, since
    since = since || 1.month.ago
    Ahoy::Event.where("properties ->> 'url' = '#{path}' and time > ?", since).count
  end
end
