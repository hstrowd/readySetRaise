class PledgesController < ApplicationController
  before_action :authenticate_user!
  before_action :lookup_pledge, only: [:show]

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

  def lookup_pledge
    @team = Team.find_by_id(params[:id]) if params[:id]

    if !@team
      flash[:alert] = 'Unable to find requested team.'
      redirect_to organization_path
    end
  end

  def is_valid_team?(team_id)
    return true if team_id && Team.find_by_id(team_id)

    flash[:alert] = 'Please select the organization for which you\'d like to submit a new pledge.'
    redirect_to organizations_path
    return false
  end

  def pledge_params
    input_params = params.require(:pledge).permit(:team_id, :amount)

    input_params
  end
end
