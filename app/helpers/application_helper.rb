module ApplicationHelper
  def secure_protocol
    return 'http' if Rails.env.production?
    return 'http'
  end

  def json_string(value)
    (value || '').to_json.html_safe
  end
end
