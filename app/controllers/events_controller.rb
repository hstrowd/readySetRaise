class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :lookup_event, only: [:show, :edit, :update]

  def new
    fundraiser_id = params[:fundraiser_id]
    return if !is_valid_fundraiser?(fundraiser_id)

    @event = Event.new(fundraiser_id: fundraiser_id)
  end

  def create
    return if !is_valid_fundraiser?(event_params[:fundraiser_id])

    @event = Event.new(event_params)
    @event.creator = current_user

    if !@event.save
      render :new
      return
    end

    redirect_to @event
    return
  end

  def update
    if !@event.update_attributes(event_params)
      render :edit
      return
    end

    redirect_to @event
    return
  end


private

  def lookup_event
    @event = Event.find_by_id(params[:id]) if params[:id]

    if !@event
      flash[:alert] = 'Unable to find requested event.'
      redirect_to organization_path
    end
  end

  def is_valid_fundraiser?(fundraiser_id)
    return true if fundraiser_id && Fundraiser.find_by_id(fundraiser_id)

    flash[:alert] = 'Please select the organization for which you\'d like to create a new event.'
    redirect_to organizations_path
    return false
  end

  def event_params
    input_params = params.require(:event).permit(:title, :description, :fundraiser_id, :start_time, :end_time)

    # Parse date values.
    if input_params.has_key?(:start_time)
      input_params[:start_time] = DateTime.iso8601(input_params[:start_time])
    end
    if input_params.has_key?(:end_time)
      input_params[:end_time] = DateTime.iso8601(input_params[:end_time])
    end

    input_params
  end
end
