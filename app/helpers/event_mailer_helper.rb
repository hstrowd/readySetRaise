module EventMailerHelper
  def humanize_time(time)
    central_time_for(time).strftime("%m/%d/%Y at %I:%M%P CST")
  end

  def central_time_for(time)
    zone = ActiveSupport::TimeZone.new("Central Time (US & Canada)")
    time.in_time_zone(zone)
  end
end
