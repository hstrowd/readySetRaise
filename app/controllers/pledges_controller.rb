class PledgesController < ApplicationController

  def new
    team_id = params[:team_id]
    return if !is_valid_team?(team_id)

    @pledge = Pledge.new(team_id: team_id)
  end

  def create
    team_id = pledge_params[:team_id]
    return if !is_valid_team?(team_id)

    team = Team.find_by_id(team_id)
    if team.event.has_ended?
      flash[:alert] = 'The event has ended. Please contact the coordinator directly to submit any further pledges/or donations.'
      redirect_to team.event
      return
    end

    @pledge = Pledge.new(pledge_params)
    @pledge.donor = current_user

    if !@pledge.save
      render :new
      return
    end

    # Notify the user that their pledge was received.
    flash[:notice] = "Thanks for your pledge! You'll receive an email after the event with a link to process your donation."

    redirect_to @pledge.event
    return
  end


private

  def is_valid_team?(team_id)
    if team_id && (team = Team.find_by_id(team_id))
      return true
    end

    flash[:alert] = "Please select the event for which you'd like to submit a new pledge."
    redirect_to events_path
    return false
  end

  def pledge_params
    begin
      params.require(:pledge)
        .permit(:team_id,
                :amount,
                :anonymous,
                :monthly,
                :comment)
    rescue ActionController::ParameterMissing => e
      logger.info "Failed to parse pledge params from #{params.inspect}"
      {}
    end
  end
end
