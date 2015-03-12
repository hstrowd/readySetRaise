require 'rails_helper'

RSpec.describe EventMailer, type: :mailer do
  before :each do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  describe '#pledge_recap' do
    describe 'when event has not ended' do
      it 'does not send an email' do
        user = create :user
        event = create :event, end_time: DateTime.now + 3.hours

        ActionMailer::Base.deliveries.clear
        expect(EventMailer.pledge_recap(user, event)).to be_a(ActionMailer::Base::NullMail)
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    describe 'when event has ended' do
      before :each do
        @event = create :event, {
          start_time: DateTime.now - 4.hours,
          end_time: DateTime.now - 3.hours
        }
        @team = create :team, event: @event
      end

      describe 'when user has no pledges for event' do
        it 'does not send an email' do
          user = create :user

          ActionMailer::Base.deliveries.clear
          expect(EventMailer.pledge_recap(user, @event)).to be_a(ActionMailer::Base::NullMail)
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end

      describe 'when user has pledges for event' do
        describe "when user has both monthly and one-time pledges" do
          it 'sends a pledge recap email' do
            user = create :user
            pledge_1 = create :pledge, {
              donor: user,
              team: @team
            }
            pledge_2 = create :pledge, {
              donor: user,
              team: @team,
              monthly: true
            }
            pledge_3 = create :pledge, {
              donor: user,
              team: @team,
              monthly: false
            }
            pledge_4 = create :pledge, {
              donor: user,
              team: @team,
              monthly: true
            }

            ActionMailer::Base.deliveries.clear
            email = EventMailer.pledge_recap(user, @event)
            expect(email).to_not be_nil
            expect(email.to.count).to eq 1
            expect(email.to[0]).to eq user.email
          end
        end

        describe "when user has only one-time pledges" do
          it 'sends a pledge recap email' do
            user = create :user
            pledge_1 = create :pledge, {
              donor: user,
              team: @team,
              monthly: false
            }
            pledge_2 = create :pledge, {
              donor: user,
              team: @team,
              monthly: false
            }

            ActionMailer::Base.deliveries.clear
            email = EventMailer.pledge_recap(user, @event)
            expect(email).to_not be_nil
            expect(email.to.count).to eq 1
            expect(email.to[0]).to eq user.email
          end
        end

        describe "when user has only monthly pledges" do
          it 'sends a pledge recap email' do
            user = create :user
            pledge_1 = create :pledge, {
              donor: user,
              team: @team,
              monthly: true
            }
            pledge_2 = create :pledge, {
              donor: user,
              team: @team,
              monthly: true
            }

            ActionMailer::Base.deliveries.clear
            email = EventMailer.pledge_recap(user, @event)
            expect(email).to_not be_nil
            expect(email.to.count).to eq 1
            expect(email.to[0]).to eq user.email
          end
        end
      end
    end
  end
end
