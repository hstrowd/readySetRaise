module EventsHelper
  def plegde_progress_percent(event)
    if (event.pledge_target == 0)
      0
    else
      (event.pledge_total / event.pledge_target * 100).round()
    end
  end
end
