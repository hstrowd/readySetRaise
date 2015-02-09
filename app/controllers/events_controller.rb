class EventsController < ApplicationController
  include DateHelper

  respond_to :html, :json
  before_action :authenticate_user!, except: [:show]
  before_action :lookup_event, except: [:new, :create]

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

  def dashboard
  end

  def pledge_breakdown
    pledge_breakdown = @event.teams.order(:name).inject([]) do |donations, team|
      donations << [team.name, team.pledge_total]
      donations
    end

    respond_with(pledge_breakdown)
  end

private

  def lookup_event
    @event = Event.find_by_id(params[:id]) if params[:id]

    if !@event
      # TODO: Consider handling this differently for JSON requests.

      flash[:alert] = 'Unable to find requested event.'
      if current_user
        redirect_to organizations_path
      else
        redirect_to root_path
      end
    end
  end

  def is_valid_fundraiser?(fundraiser_id)
    if fundraiser_id && (fundraiser = Fundraiser.find_by_id(fundraiser_id))
      members = fundraiser.organization.members
      return true if members.to_a.index { |user| user.id == current_user.id }
    end

    flash[:alert] = 'Please select the organization for which you\'d like to create a new event.'
    redirect_to organizations_path
    return false
  end

  def event_params
    input_params = {}
    begin
      input_params = params.require(:event)
        .permit(:title,
                :description,
                :fundraiser_id,
                :start_time,
                :end_time)
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
