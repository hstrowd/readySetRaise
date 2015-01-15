class TeamsController < ApplicationController
  before_action :authenticate_user!

  def index
    @teams = Team.all
  end

  def show
    if params[:id]
      @team = Team.find_by_id(params[:id])
    end

    if !@team
      flash[:alert] = 'Unable to find requested team.'
      redirect_to organization_path
    end
  end

  def new
    prep_new_team(params[:event_id])
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to @team.event
    else
      prep_new_team(params.team.try(:event_id))
    end
  end

private

  def prep_new_team(event_id)
    if !Event.find_by_id(event_id)
      flash[:alert] = 'No event specified for new team.'
      redirect_to organization_path
    end
    @team = Team.new(event_id: event_id)
  end

  def team_params
    input_params = params.require(:team).permit(:name, :event_id, :pledge_target)

    input_params
  end

end
