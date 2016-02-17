module TeamsHelper
  def is_event_member(team)
    team.event.is_member?(current_user)
  end
end
