class EventMailer < ApplicationMailer
  def pledge_recap(user, event)
#    if !@event.has_ended?
#      logger.warn "Attempted to send pledge recap to user ${user.id} before event {event.id} ended."
#      return
#    end

    @user = user
    @event = event
    @pledges = event.pledges.where(donor: user).order(created_at: :desc)

    if @pledges.empty?
      logger.warn "Attempted to send pledge recap to user ${user.id} for event ${event.id}, but no pledges were found for this user."
      return
    end

    # TODO: Update this to allow clients to specify their own mail structure.
    mail(to: @user.email, subject: "#{event.title} - Pledge Recap")
  end
end
