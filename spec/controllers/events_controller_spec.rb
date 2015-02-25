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
          describe "when fundraiser has not started" do
            before :each do
              @fundraiser.pledge_start_time = DateTime.now + 3.days
              @fundraiser.pledge_end_time = DateTime.now + 8.days
              @fundraiser.save!
            end

            it "renders the new template with start time of the fundraiser's pledge start time" do
              @fundraiser.organization.members << @current_user

              get :new, fundraiser_id: @fundraiser.id

              expect(response).to render_template :new
              expect(assigns(:event).start_time).to eq @fundraiser.pledge_start_time
              expect(assigns(:event).end_time).to eq @fundraiser.pledge_start_time
            end
          end

          describe "when fundraiser has started" do
            before :each do
              @fundraiser.pledge_start_time = DateTime.now - 3.days
              @fundraiser.pledge_end_time = DateTime.now + 2.days
            end

            it "renders the new template with start time of the fundraiser's pledge start time" do
              @fundraiser.organization.members << @current_user

              get :new, fundraiser_id: @fundraiser.id

              expect(response).to render_template :new
              expect(assigns(:event).start_time).to be_nil
              expect(assigns(:event).end_time).to be_nil
            end
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
                  end_time: (DateTime.now + 3.hours).iso8601,
                  team_descriptor_id: 1
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
          pledge_1 = create :pledge, team: team
          pledge_2 = create :pledge, team: team
          pledge_3 = create :pledge, team: team

          get :show, format: :json, id: @event.id

          expect(response).to render_template :show

          json_event = JSON.parse(response.body)
          expect(json_event['eventID']).to eq @event.id

          # Includes pledge info
          json_pledges = json_event['pledges']
          expect(json_pledges.count).to eq 3

          json_pledge = json_pledges.bsearch { |p| pledge_1.id == p['pledgeID'] }
          expect(json_pledge).to_not be_nil
          expect(json_pledge['amount']).to eq pledge_1.amount

          # Pledges include their associated team
          json_team = json_pledge['team']
          expect(json_team).to_not be_nil
          expect(json_team['name']).to eq team.name

          # Pledges include their associated donor
          json_donor = json_pledge['donor']
          expect(json_donor).to_not be_nil
          expect(json_donor['email']).to eq pledge_1.donor.email
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

      describe "when JSON is requested" do
        it "returns a 404" do
          get :show, format: :json, id: -1

          expect(response).to have_http_status 404
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to_not be_nil
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

  describe "GET pledge_breakdown" do
    describe "when user is logged in" do
      before :each do
        sign_in create :user
      end

      describe "when the requested record is found" do
        it "should render the dashboard template" do
          event = create :event

          team_1 = create :team, event: event
          pledge_1_1 = create :pledge, team: team_1
          pledge_1_2 = create :pledge, team: team_1
          pledge_1_3 = create :pledge, team: team_1
          team_1_total = pledge_1_1.amount +
            pledge_1_2.amount +
            pledge_1_3.amount

          team_2 = create :team, event: event
          pledge_2_1 = create :pledge, team: team_2
          pledge_2_2 = create :pledge, team: team_2
          team_2_total = pledge_2_1.amount +
            pledge_2_2.amount

          team_3 = create :team, event: event
          pledge_3_1 = create :pledge, team: team_3
          pledge_3_2 = create :pledge, team: team_3
          pledge_3_3 = create :pledge, team: team_3
          pledge_3_4 = create :pledge, team: team_3
          team_3_total = pledge_3_1.amount +
            pledge_3_2.amount +
            pledge_3_3.amount +
            pledge_3_4.amount

          get :pledge_breakdown, format: :json, id: event.id

          json_pledge_breakdown = JSON.parse(response.body)

          # Response will be ordered by team name.
          # Since team names are sequenced, it should be 1, 2, 3.
          team_1_breakdown = json_pledge_breakdown[0]
          expect(team_1_breakdown[0]).to eq "#{team_1.name} (3)"
          expect(team_1_breakdown[1]).to eq team_1_total

          team_2_breakdown = json_pledge_breakdown[1]
          expect(team_2_breakdown[0]).to eq "#{team_2.name} (2)"
          expect(team_2_breakdown[1]).to eq team_2_total

          team_3_breakdown = json_pledge_breakdown[2]
          expect(team_3_breakdown[0]).to eq "#{team_3.name} (4)"
          expect(team_3_breakdown[1]).to eq team_3_total
        end
      end

      describe "when the requested record is not found" do
        it "redirects to orgs index" do
          get :pledge_breakdown, format: :json, id: 0

          expect(response).to have_http_status 404
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to_not be_nil
        end
      end
    end

    describe "when user is not logged in" do
      it "redirects to login form" do
        get :pledge_breakdown, format: :json, id: 0

        expect(response).to have_http_status 401

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to_not be_nil
      end
    end
  end

end
