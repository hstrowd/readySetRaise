class UrlValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |url_field|
      begin
        next if record.send(url_field).blank?
        uri = URI.parse(record.send(url_field))
        if !uri.kind_of?(URI::HTTP)
          record.errors[url_field] << "must be a valid HTTP/HTTPS URL."
        end
      rescue URI::InvalidURIError
        record.errors[url_field] << "must be a valid HTTP/HTTPS URL."
      end
    end
  end
end
