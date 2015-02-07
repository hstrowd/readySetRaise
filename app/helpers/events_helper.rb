module EventsHelper
  def pledge_total_by_team(event)
    event.teams.inject({}) do |donations, team|
      donations[team.name] = team.pledge_total
      donations
    end
  end

  def plegde_progress_percent(event)
    if (event.pledge_target == 0)
      0
    else
      (event.pledge_total / event.pledge_target * 100).round()
    end
  end
end
