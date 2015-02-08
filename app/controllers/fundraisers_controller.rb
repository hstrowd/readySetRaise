class FundraisersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :lookup_fundraiser, only: [:show, :edit, :update]

  def index
    # TODO: Make this only active fundraisers.
    @fundraisers = Fundraiser.all
  end

  def new
    return if redirect_to_new_org?

    org_id = params[:organization_id]
    return if !is_valid_org?(org_id)

    @fundraiser = Fundraiser.new(organization_id: org_id)
  end

  def create
    return if !is_valid_org?(fundraiser_params[:organization_id])

    @fundraiser = Fundraiser.new(fundraiser_params)
    @fundraiser.creator = current_user

    if !@fundraiser.save
      return if redirect_to_new_org?

      render :new
      return
    end

    redirect_to new_fundraiser_event_path(@fundraiser)
    return
  end

  def update
    if !@fundraiser.update_attributes(fundraiser_params)
      render :edit
      return
    end

    redirect_to @fundraiser
    return
  end


private

  def lookup_fundraiser
    @fundraiser = Fundraiser.find_by_id(params[:id]) if params[:id]

    if !@fundraiser
      flash[:alert] = 'Unable to find requested fundraiser.'
      redirect_to action: "index"
    end
  end

  def redirect_to_new_org?
    # Lookp the organizations for this user.
    @organizations = current_user.organizations
    if @organizations.empty?
      redirect_to new_organization_path
      return
    end
  end

  def is_valid_org?(org_id)
    return true if org_id && Organization.find_by_id(org_id)

    flash[:alert] = 'Please select the organization for which you\'d like to create a new fundraiser.'
    redirect_to organizations_path
    return false
  end

  def fundraiser_params
    input_params = params.require(:fundraiser).permit(:title, :description, :organization_id, :pledge_start_time, :pledge_end_time)

    # Parse date values.
    if input_params.has_key?(:pledge_start_time)
      input_params[:pledge_start_time] = DateTime.iso8601(input_params[:pledge_start_time])
    end
    if input_params.has_key?(:pledge_end_time)
      input_params[:pledge_end_time] = DateTime.iso8601(input_params[:pledge_end_time])
    end

    input_params
  end

end
