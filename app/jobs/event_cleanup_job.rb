# In development this job will need to be run manually
# (e.g. bin/rails runner -e development 'EventCleanupJob.perform').
# In production we are using the scheduler Heroku addon.
class EventCleanupJob
  def self.perform
    puts "Starting event cleanup job."
    completedEvents = Event.where("end_time > ? AND cleanup_time IS NULL", (DateTime.now - 36.hours))

    completedEvents.each do |event|
      puts "Cleaning up event #{event.id}."
      send_pledge_recap_emails(event)

      event.cleanup_time = DateTime.now
      event.save
    end
    puts "Completed event cleanup job."
  end

  def self.send_pledge_recap_emails(event)
    donors = event.pledges.to_ary.collect { |pledge| pledge.donor }.uniq
    donors.each do |user|
      puts "Sending pledge recap email to user #{user.id} for event #{event.id}."
      EventMailer.pledge_recap(user, event).deliver
    end
  end
end
