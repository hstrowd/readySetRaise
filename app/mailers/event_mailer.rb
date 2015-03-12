class EventMailer < ApplicationMailer
  layout 'mailer'

  def pledge_recap(user, event)
    if !event.has_ended?
      logger.warn "Attempted to send pledge recap to user #{user.id} before event #{event.id} ended."
      return
    end

    @user = user
    @event = event
    @pledges = event.pledges.where(donor: user).order(created_at: :asc)

    if @pledges.empty?
      logger.warn "Attempted to send pledge recap to user #{user.id} for event #{event.id}, but no pledges were found for this user."
      return
    end

    @one_time_total = @pledges.where(monthly: false).sum(:amount)
    @monthly_total = @pledges.where(monthly: true).sum(:amount)

    mail(to: @user.email, subject: "#{event.title} - Pledge Recap")
  end
end
