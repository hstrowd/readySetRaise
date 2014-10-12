class OrganizationsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @orgs = Organization.all
  end

  def show
    if params[:id]
      @org = Organization.find_by_id(params[:id])
    end

    if !@org
      flash[:alert] = 'Unable to find requested organization.'
      redirect_to action: "index"
    end
  end

  def new
    if !current_user
      # TODO: Mark this session as wanting to create an organization
      redirect_to new_registration_path(:user)
      return
    end
    @org = Organization.new
  end

  def create
    @org = Organization.new(params[:organization])
    if @org.save
      # TODO: Redirect them to creating an event
      redirect_to @org
    else
      render :new
    end
  end

end
