# In development this job will need to be run manually
# (e.g. bin/rails runner -e development 'EventCleanupJob.perform').
# In production we are using the scheduler Heroku addon.
class EventCleanupJob
  def self.perform
    Rails.logger.info "Starting event cleanup job."
    completedEvents = Event.where("end_time > ? AND cleanup_time IS NULL", (DateTime.now - 36.hours))

    completedEvents.each do |event|
      Rails.logger.info "Cleaning up event #{event.id}."
      send_pledge_recap_emails(event)

      event.cleanup_time = DateTime.now
      event.save
    end
    Rails.logger.info "Completed event cleanup job."
  end

private

  def self.send_pledge_recap_emails(event)
    donors = event.pledges.to_ary.collect { |pledge| pledge.donor }.uniq
    donors.each do |user|
      Rails.logger.debug "Sending pledge recap email to user #{user.id} for event #{event.id}."
      email = EventMailer.pledge_recap(user, event)
      if email && !email.is_a?(ActionMailer::Base::NullMail)
        email.deliver
      end
    end
  end
end
