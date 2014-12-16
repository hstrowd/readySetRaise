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
      redirect_to action: "index"
    end
  end

  # TODO: Figure out how the fundraiser ID will be provided here.
  def new
    prep_new_event(params[:fundraiser_id])
  end

  def create
    @event = Event.new(event_params)
    @event.creator = current_user
    if @event.save
      redirect_to @event
    else
      prep_new_event(params.event.try(:fundraiser_id))
    end
  end

private

  def prep_new_event(fundraiser_id)
    if !Fundraiser.find_by_id(fundraiser_id)
      flash[:alert] = 'No fundraiser specified for new event.'
      redirect_to organization_path
    end
    @event = Event.new(fundraiser_id: fundraiser_id)
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
