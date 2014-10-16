class FundraisersController < ApplicationController
  before_action :authenticate_user!

  def index
    @fundraisers = Fundraiser.all
  end

  def show
    if params[:id]
      @fundraiser = Fundraiser.find_by_id(params[:id])
    end

    if !@fundraiser
      flash[:alert] = 'Unable to find requested fundraiser.'
      redirect_to action: "index"
    end
  end

  def new
    # TODO: Lookp the organizations for just this user.
    @orgs = Organization.all
    @fundraiser = Fundraiser.new
  end

  def create
    @fundraiser = Fundraiser.new(fundraiser_params)
    if @fundraiser.save
      # TODO: Redirect them to creating an event
      redirect_to @fundraiser
    else
      render :new
    end
  end

  private

  def fundraiser_params
    params.require(:fundraiser).permit(:title, :description, :pledge_start_time, :pledge_end_time)
  end

end
