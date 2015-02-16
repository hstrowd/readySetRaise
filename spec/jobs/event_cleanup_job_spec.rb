require 'rails_helper'

RSpec.describe EventCleanupJob do
  describe '.perform' do
    before :each do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    after :each do
      ActionMailer::Base.deliveries.clear
    end

    describe 'when an event recently ended' do
      before :each do
        @donor_1 = create :user
        @donor_2 = create :user
        @donor_3 = create :user

        @event_1 = create :event, {
          start_time: (DateTime.now - 7.hours),
          end_time: (DateTime.now - 2.hours),
          creator: @donor_1
        }

        @team_1_1 = create :team, event: @event_1

        @pledge_1_1_1 = create :pledge, {
          team: @team_1_1,
          donor: @donor_2
        }
        @pledge_1_1_2 = create :pledge, {
          team: @team_1_1,
          donor: @donor_1
        }
        @pledge_1_1_3 = create :pledge, {
          team: @team_1_1,
          donor: @donor_2
        }

        @team_1_2 = create :team, event: @event_1

        @pledge_1_1_1 = create :pledge, {
          team: @team_1_2,
          donor: @donor_3
        }
        @pledge_1_1_2 = create :pledge, {
          team: @team_1_2,
          donor: @donor_2
        }
      end

      it 'sends pledge recap email to each donor' do
        expected_emails = {
          @donor_1.email => {
            subject: "#{@event_1.title} - Pledge Recap"
          },
          @donor_2.email => {
            subject: "#{@event_1.title} - Pledge Recap"
          },
          @donor_3.email => {
            subject: "#{@event_1.title} - Pledge Recap"
          }
        }

        ActionMailer::Base.deliveries.clear

        job_start_time = DateTime.now
        EventCleanupJob.perform
        job_end_time = DateTime.now

        post_event_1 = Event.find @event_1.id
        expect(post_event_1.cleanup_time).to be >= job_start_time
        expect(post_event_1.cleanup_time).to be <= job_end_time

        expect(ActionMailer::Base.deliveries.count).to eq 3

        ActionMailer::Base.deliveries.each do |delivery|
          expect(delivery.to.count).to eq 1

          email_expectations = expected_emails[delivery.to[0]]
          expect(email_expectations).to_not be_nil

          expect(delivery.subject).to eq email_expectations[:subject]
        end
      end
    end
    describe 'when an event has not yet ended' do
      before :each do
        @event = create :event, {
          start_time: (DateTime.now - 3.hours),
          end_time: (DateTime.now + 1.hour)
        }
      end

      it "does not cleanup the event" do
        EventCleanupJob.perform

        post_event = Event.find @event.id
        expect(post_event.cleanup_time).to be_nil
      end
    end
  end
end
