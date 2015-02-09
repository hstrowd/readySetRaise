require 'rails_helper'

RSpec.describe EventsController, :type => :controller do
  render_views

  # ======== Index Action ========

  describe "GET index" do
    it "should not be routable" do
      expect(:get => '/events').not_to be_routable
    end
  end


  # ======== New Action ========

  describe "GET new" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when associated fundraiser is found" do
        before :each do
          @fundraiser = create :fundraiser
        end

        describe "when current user is member of org" do
          it "renders the new template" do
            @fundraiser.organization.members << @current_user

            get :new, fundraiser_id: @fundraiser.id

            expect(response).to render_template :new
          end
        end

        describe "when current user is not member of org" do
          it "redirects to orgs index" do
            get :new, fundraiser_id: @fundraiser.id
            expect(response).to redirect_to organizations_path
          end
        end
      end

      describe "when associated fundraiser is not found" do
        it "redirects to orgs index" do
          get :new, fundraiser_id: -1
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        get :new, fundraiser_id: 0
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Create Action ========

  describe "POST create" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when associated fundraiser is found" do
        before :each do
          @fundraiser = create :fundraiser
        end

        describe "when the current user is member of org" do
          before :each do
            @fundraiser.organization.members << @current_user
          end

          describe "when valid attributes are provided" do
            it "creates a new event" do
              expect {
                post :create, event: {
                  title: 'Test Event',
                  description: 'Test event description.',
                  fundraiser_id: @fundraiser.id,
                  start_time: DateTime.now.iso8601,
                  end_time: (DateTime.now + 3.hours).iso8601
                }
              }.to change{ Event.count }.by 1

              expect(response).to redirect_to Event.last
            end
          end

          describe "when invalid attributes are provided" do
            it "rerenders the edit form" do
              expect {
                post :create, event: {
                  title: nil,
                  description: 'Test event description.',
                  fundraiser_id: @fundraiser.id,
                  start_time: DateTime.now.iso8601,
                  end_time: (DateTime.now + 3.hours).iso8601
                }
              }.to_not change{ Event.count }

              expect(response).to render_template :new
            end

            it "does not error due to invalid date formats" do
              expect {
                post :create, event: {
                  title: nil,
                  description: 'Test event description.',
                  fundraiser_id: @fundraiser.id,
                  start_time: DateTime.now.strftime('%m/%d/%y at %I:%M%p'),
                  end_time: (DateTime.now + 3.hours).strftime('%m/%d/%y at %I:%M%p')
                }
              }.to_not change{ Event.count }

              expect(response).to render_template :new
            end

            it "does not error due to garbage parameters" do
              expect {
                post :create, foo: 123
              }.to_not change{ Event.count }

              expect(response).to redirect_to organizations_path
            end
          end
        end

        describe "when the current user is not member of org" do
          it "redirect to orgs index" do
            post :create, event: {
              title: 'Test event',
              description: 'Test event description.',
              fundraiser_id: @fundraiser.id,
              start_time: DateTime.now.iso8601,
              end_time: (DateTime.now + 3.hours).iso8601
            }
            expect(response).to redirect_to organizations_path
          end
        end
      end

      describe "when associated fundraiser is not found" do
        it "redirect to orgs index" do
          post :create, event: {
            title: 'Test event',
            description: 'Test event description.',
            fundraiser_id: -1,
            start_time: DateTime.now.iso8601,
            end_time: (DateTime.now + 3.hours).iso8601
          }
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        post :create, event: {
          title: 'Test event',
          description: 'Test event description.',
          fundraiser_id: 1,
          start_time: DateTime.now.iso8601,
          end_time: (DateTime.now + 3.hours).iso8601
        }
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Show Action ========

  describe "GET show" do
    describe "when requested record is found" do
      before :each do
        @event = create :event
      end

      it "renders the show template" do
        get :show, id: @event.id

        expect(response).to render_template :show
        expect(assigns(:event)).to eq @event
      end

      describe "when JSON is requested" do
        it "should return valid JSON" do
          team = create :team, event: @event
          pledge1 = create :pledge, team: team
          pledge2 = create :pledge, team: team
          pledge3 = create :pledge, team: team

          get :show, format: :json, id: @event.id

          expect(response).to render_template :show

          jsonEvent = JSON.parse(response.body)
          expect(jsonEvent['eventID']).to eq @event.id

          # Includes pledge info
          jsonPledges = jsonEvent['pledges']
          expect(jsonPledges.count).to eq 3

          jsonPledge = jsonPledges.bsearch { |p| pledge1.id == p['pledgeID'] }
          expect(jsonPledge).to_not be_nil
          expect(jsonPledge['amount']).to eq pledge1.amount

          # Pledges include their associated team
          jsonTeam = jsonPledge['team']
          expect(jsonTeam).to_not be_nil
          expect(jsonTeam['name']).to eq team.name

          # Pledges include their associated donor
          jsonDonor = jsonPledge['donor']
          expect(jsonDonor).to_not be_nil
          expect(jsonDonor['email']).to eq pledge1.donor.email
        end
      end
    end

    describe "when requested record is not found" do
      describe "when user is logged in" do
        before :each do
          @current_user = create :user
          sign_in @current_user
        end

        it "redirects to orgs index" do
          get :show, id: -1
          expect(response).to redirect_to organizations_path
        end
      end

      describe "when user is not logged in" do
        it "redirects to home page" do
          get :show, id: -1
          expect(response).to redirect_to root_path
        end
      end
    end
  end


  # ======== Edit Action ========

  describe "GET edit" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when requested record is found" do
        it "renders the edit template" do
          event = create :event
          get :edit, id: event.id
          expect(response).to render_template :edit
        end
      end

      describe "when requested record is not found" do
        it "redirects to orgs index" do
          get :edit, id: -1
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        get :edit, id: 0
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Update Action ========

  describe "PUT update" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when requested record is found" do
        before :each do
          @event = create :event
        end

        describe "when record update succeeds" do
          it "modifies and shows the record" do
            newTitle = "New Event Title"
            expect(@event.title).to_not eq newTitle

            put :update, id: @event.id, event: { title: newTitle}

            expect(Event.find(@event.id).title).to eq newTitle
            expect(response).to redirect_to event_path(@event)
          end
        end

        describe "when record upadte fails" do
          it "rerenders the edit form" do
            put :update, id: @event.id, event: { title: nil}
            expect(response).to render_template :edit
          end

          it "does not error due to garbage parameters" do
            put :update, id: 1, foo: 123

            expect(response).to redirect_to organizations_path
          end
        end
      end

      describe "when requested record is not found" do
        it "redirects to orgs index" do
          put :update, id: -1
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        put :update, id: 0
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Destroy Action ========

  describe "DELETE destroy" do
    it "should not be routable" do
      event = create :event
      expect(:destroy => '/events/#{event.id}').not_to be_routable
    end
  end


  # ======== Dashboard Action ========

  describe "GET dashboard" do
    describe "when user is logged in" do
      before :each do
        sign_in create :user
      end

      describe "when the requested record is found" do
        it "should render the dashboard template" do
          event = create :event

          get :dashboard, id: event.id

          expect(response).to render_template :dashboard
          expect(assigns(:event)).to eq event
        end
      end

      describe "when the requested record is not found" do
        it "redirects to orgs index" do
          get :dashboard, id: 0
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when user is not logged in" do
      it "redirects to login form" do
        get :dashboard, id: 0
        expect(response).to redirect_to new_user_session_path
      end
    end
  end


  # ======== Pledge Breakdown Action ========

  # TODO: Implement me.

end
