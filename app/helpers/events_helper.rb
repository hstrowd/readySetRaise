module EventsHelper
  def pledge_progress_percent(event)
    if (event.pledge_target == 0)
      0
    else
      (event.pledge_total / event.pledge_target * 100).round
    end
  end

  def show_url(event)
    if (!event.url_key.blank?)
      return "#{root_url(protocol: secure_protocol)}#{event.organization.url_key}/#{event.url_key}"
    else
      return event_url(event, protocol: secure_protocol)
    end
  end
end
