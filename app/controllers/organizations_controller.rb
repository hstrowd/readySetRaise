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
    @org = Organization.new(organization_params)
    @org.creator = current_user
    @org.is_verified = false
    if @org.save
      # Make the current user a member.
      @org.members << current_user

      redirect_to new_fundraiser_path
    else
      render :new
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :description, :url_key, :homepage_url, :donation_url)
  end

end
