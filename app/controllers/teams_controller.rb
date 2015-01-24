class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :lookup_team, only: [:show, :edit, :update]

  def new
    event_id = params[:event_id]
    return if !is_valid_event?(event_id)

    @team = Team.new(event_id: event_id)
  end

  def create
    return if !is_valid_event?(team_params[:event_id])

    @team = Team.new(team_params)

    if !@team.save
      render :new
      return
    end

    redirect_to @team.event
    return
  end

  def update
    if !@team.update_attributes(team_params)
      render :edit
      return
    end

    redirect_to @team
    return
  end

private

  def lookup_team
    @team = Team.find_by_id(params[:id]) if params[:id]

    if !@team
      flash[:alert] = 'Unable to find requested team.'
      redirect_to organization_path
    end
  end

  def is_valid_event?(event_id)
    return true if event_id && Event.find_by_id(event_id)

    flash[:alert] = 'Please select the organization for which you\'d like to create a new team.'
    redirect_to organizations_path
    return false
  end

  def team_params
    input_params = params.require(:team).permit(:name, :event_id, :pledge_target)

    input_params
  end

end
