module TeamsHelper
  def is_org_member(team)
    team.organization.members.include?(current_user)
  end
end
