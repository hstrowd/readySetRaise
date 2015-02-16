class FundraisersController < ApplicationController
  include DateHelper

  before_action :authenticate_user!, except: [:show]
  before_action :lookup_fundraiser, only: [:show, :edit, :update]

  def new
    org_id = params[:organization_id]
    return if !is_valid_org?(org_id)

    @fundraiser = Fundraiser.new(organization_id: org_id)
  end

  def create
    return if !is_valid_org?(fundraiser_params[:organization_id])

    @fundraiser = Fundraiser.new(fundraiser_params)
    @fundraiser.creator = current_user

    if !@fundraiser.save
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
      if current_user
        redirect_to organizations_path
      else
        redirect_to root_path
      end
      return false
    end
  end

  def is_valid_org?(org_id)
    if org_id &&
        (org = Organization.find_by_id(org_id))
      return true if org.members.to_a.index { |user| user.id == current_user.id }
    end

    flash[:alert] = 'Please select the organization for which you\'d like to create a new fundraiser.'
    redirect_to organizations_path
    return false
  end

  def fundraiser_params
    input_params = {}
    begin
      input_params = params.require(:fundraiser)
        .permit(:title,
                :description,
                :organization_id,
                :pledge_start_time,
                :pledge_end_time)
    rescue ActionController::ParameterMissing => e
      logger.info "Failed to parse fundraiser params from #{params.inspect}"
    end

    # Parse date values.
    if input_params.has_key?(:pledge_start_time)
      input_params[:pledge_start_time] = parseIso8601Date(input_params[:pledge_start_time])
    end
    if input_params.has_key?(:pledge_end_time)
      input_params[:pledge_end_time] = parseIso8601Date(input_params[:pledge_end_time])
    end

    input_params
  end

end
