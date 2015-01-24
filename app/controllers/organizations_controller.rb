class OrganizationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :new]
  before_action :lookup_org, only: [:show, :edit, :update]

  def index
    @orgs = Organization.all
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

    if !@org.save
      render :new
      return
    end

    # Make the current user a member.
    @org.members << current_user

    redirect_to new_fundraiser_path
    return
  end

  def update
    if !@org.update_attributes(organization_params)
      render :edit
      return
    end

    redirect_to @org
    return
  end


private

  def lookup_org
    @org = Organization.find_by_id(params[:id])if params[:id]

    if !@org
      flash[:alert] = 'Unable to find requested organization.'
      redirect_to action: "index"
      return
    end
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :url_key, :homepage_url, :donation_url)
  end

end
