class OrganizationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

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
    @org = Organization.new
  end

  def create
    @org = Organization.new(params[:organization])
    if @org.save
      redirect_to @org
    else
      render :new
    end
  end

end
