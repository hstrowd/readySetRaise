class PledgesController < ApplicationController
  before_action :authenticate_user!

  def show
    if params[:id]
      @pledge = Pledge.find_by_id(params[:id])
    end

    if !@pledge
      flash[:alert] = 'Unable to find requested team.'
      redirect_to organization_path
    end
  end

  def new
    prep_new_pledge(params[:team_id])
  end

  def create
    @pledge = Pledge.new(pledge_params)
    if @pledge.save
      redirect_to @pledge.team
      return
    else
      render :new
      return
    end
  end

private

  def prep_new_pledge(team_id)
    if !Team.find_by_id(team_id)
      flash[:alert] = 'No team specified for new pledge.'
      redirect_to organization_path
    end
    @pledge = Pledge.new(team_id: team_id)
  end

  def pledge_params
    input_params = params.require(:pledge).permit(:team_id, :amount)

    input_params
  end
end
