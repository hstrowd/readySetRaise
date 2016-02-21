class EventsController < ApplicationController
  include DateHelper

  respond_to :html, :json
  layout "raw", only: [:dashboard]

  before_action :authenticate_user!, except: [:show]
  before_action :require_admin!, only: [:new, :create, :edit, :update]
  before_action :lookup_event, except: [:index, :new, :create]

  def index
    @events = Event.where("start_time <= ? AND end_time >= ?",
                          (DateTime.now + 3.hours),
                          (DateTime.now - 3.hours))
  end

  def new
    @event = Event.new
  end

  def create
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

  def dashboard
  end

  def pledge_breakdown
    pledge_breakdown = @event.teams.order(:name).inject([]) do |donations, team|
      data_label = "#{team.name} (#{team.pledges.count})"
      donations << [data_label, team.pledge_total]
      donations
    end

    respond_with(pledge_breakdown)
  end

private

  def lookup_event
    @event = Event.find_by_id(params[:id]) if params[:id]

    # Check if the url_keys were specified for this request.
    if !@event && params[:event_url_key]
      @event = Event.find_by_url_key(params[:event_url_key])
    end

    if !@event
      respond_to do |format|
        format.html {
          flash[:alert] = 'Unable to find requested event.'
          if current_user
            redirect_to events_path
          else
            redirect_to root_path
          end
        }
        format.json { render :json => {:error => 'Event not found.'}.to_json, :status => 404 }
      end
    end
  end

  def event_params
    input_params = {}
    begin
      input_params = params.require(:event)
        .permit(:title,
                :description,
                :url_key,
                :start_time,
                :end_time,
                :logo_url,
                :team_descriptor_id)
    rescue ActionController::ParameterMissing => e
      logger.info "Failed to parse event params from #{params.inspect}"
    end

    # Parse date values.
    if input_params.has_key?(:start_time)
      input_params[:start_time] = parseIso8601Date(input_params[:start_time])
    end
    if input_params.has_key?(:end_time)
      input_params[:end_time] = parseIso8601Date(input_params[:end_time])
    end

    input_params
  end
end
