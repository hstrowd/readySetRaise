module DateHelper
  def parseIso8601Date(dateString)
    begin
      DateTime.iso8601(dateString)
    rescue ArgumentError => e
      logger.info "Failed to parse date from #{dateString}. Error: #{e.inspect}"
      nil
    end
  end
end
