class PledgesController < ApplicationController
  before_action :authenticate_user!

  def new
    team_id = params[:team_id]
    return if !is_valid_team?(team_id)

    @pledge = Pledge.new(team_id: team_id)
  end

  def create
    return if !is_valid_team?(pledge_params[:team_id])

    @pledge = Pledge.new(pledge_params)
    @pledge.donor = current_user

    if !@pledge.save
      render :new
      return
    end

    redirect_to @pledge.team
    return
  end


private

  def is_valid_team?(team_id)
    if team_id && (team = Team.find_by_id(team_id))
      members = team.event.fundraiser.organization.members
      return true if members.to_a.index { |user| user.id == current_user.id }
    end

    flash[:alert] = 'Please select the organization for which you\'d like to submit a new pledge.'
    redirect_to organizations_path
    return false
  end

  def pledge_params
    begin
      params.require(:pledge)
        .permit(:team_id,
                :amount)
    rescue ActionController::ParameterMissing => e
      logger.info "Failed to parse pledge params from #{params.inspect}"
      {}
    end
  end
end
