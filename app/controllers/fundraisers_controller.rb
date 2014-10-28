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
    # Lookp the organizations for this user.
    @organizations = current_user.organizations
    if @organizations.empty?
      redirect_to new_organization_path
    end

    @fundraiser = Fundraiser.new
  end

  def create
    @fundraiser = Fundraiser.new(fundraiser_params)
    @fundraiser.creator = current_user
    if @fundraiser.save
      # TODO: Redirect them to creating an event
      redirect_to @fundraiser
      return
    else
      @organizations = current_user.organizations
      if @organizations.empty?
        redirect_to new_organization_path
      else
        render :new
      end
      return
    end
  end

  private

  def fundraiser_params
    input_params = params.require(:fundraiser).permit(:title, :description, :organization_id, :pledge_start_time, :pledge_end_time)

    # Parse date values.
#    if input_params.has_key?(:pledge_start_time)
#      input_params[:pledge_start_time] = DateTime.iso8601(input_params[:pledge_start_time])
#    end
#    if input_params.has_key?(:pledge_end_time)
#      input_params[:pledge_end_time] = DateTime.iso8601(input_params[:pledge_end_time])
#    end

    input_params
  end

end
