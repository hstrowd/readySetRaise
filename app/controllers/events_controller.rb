class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.all
  end

  def show
    if params[:id]
      @event = Event.find_by_id(params[:id])
    end

    if !@event
      flash[:alert] = 'Unable to find requested event.'
      redirect_to organization_path
    end
  end

  # TODO: Figure out how the fundraiser ID will be provided here.
  def new
    prep_new_event(params[:fundraiser_id])
  end

  def create
    params = event_params
    @event = Event.new(params)
    @event.creator = current_user
    if @event.save
      redirect_to @event
    else
      if params.has_key?(:fundraiser_id)
        render :new
        return
      else
        flash[:alert] = 'Please select a fundraiser before creating an event.'
        redirect_to organizations_path
        return
      end
    end
  end

private

  def prep_new_event(fundraiser_id)
    if !Fundraiser.find_by_id(fundraiser_id)
      flash[:alert] = 'Unable to find fundraiser. Please try again.'
      redirect_to organizations_path
      return
    end
    @event = Event.new(fundraiser_id: fundraiser_id)
    render :new
    return
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
