require 'rails_helper'

RSpec.describe PledgesController, :type => :controller do
  render_views

  # ======== Index Action ========

  describe "GET index" do
    it "should not be routable" do
      expect(:get => '/pledges').not_to be_routable
    end
  end


  # ======== New Action ========

  describe "GET new" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when associated team is found" do
        before :each do
          @team = create :team
        end

        describe "when current user is member of org" do
          it "renders the new template" do
            @team.event.fundraiser.organization.members << @current_user

            get :new, team_id: @team.id

            expect(response).to render_template :new
          end
        end

        describe "when current user is not member of org" do
          it "renders the new template" do
            get :new, team_id: @team.id

            expect(response).to render_template :new
          end
        end
      end

      describe "when associated team is not found" do
        it "redirects to orgs index" do
          get :new, team_id: -1
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        get :new, team_id: 1
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

      describe "when associated team is found" do
        describe "when valid attributes are provided" do
          describe "before fundraiser pledge window starts" do
            it "prevents new pledges" do
              fundraiser = create :fundraiser, {
                pledge_start_time: DateTime.now + 1.day,
                pledge_end_time: DateTime.now + 3.day
              }
              event = create :event, {
                fundraiser: fundraiser,
                start_time: DateTime.now + 36.hours,
                end_time: DateTime.now + 39.hours
              }
              team = create :team, event: event

              expect {
                post :create, pledge: {
                  team_id: team.id,
                  amount: 10,
                  monthly: true,
                  anonymous: true
                }
              }.to_not change{ Pledge.count }

              expect(response).to redirect_to event
            end
          end

          describe "during fundraiser pledge window before event start" do
            it "creates a new pledge" do
              fundraiser = create :fundraiser, {
                pledge_start_time: DateTime.now - 1.day,
                pledge_end_time: DateTime.now + 3.day
              }
              event = create :event, {
                fundraiser: fundraiser,
                start_time: DateTime.now + 36.hours,
                end_time: DateTime.now + 39.hours
              }
              team = create :team, event: event

              expect {
                post :create, pledge: {
                  team_id: team.id,
                  amount: 10,
                  monthly: true,
                  anonymous: true
                }
              }.to change{ Pledge.count }.by 1

              expect(response).to redirect_to team
            end
          end

          describe "during the event" do
            it "creates a new pledge" do
              fundraiser = create :fundraiser, {
                pledge_start_time: DateTime.now - 1.day,
                pledge_end_time: DateTime.now + 3.day
              }
              event = create :event, {
                fundraiser: fundraiser,
                start_time: DateTime.now - 3.hours,
                end_time: DateTime.now + 3.hours
              }
              team = create :team, event: event

              expect {
                post :create, pledge: {
                  team_id: team.id,
                  amount: 10,
                  monthly: true,
                  anonymous: true
                }
              }.to change{ Pledge.count }.by 1

              expect(response).to redirect_to team
            end
          end

          describe "after the event ends" do
            it "rejects new pledges" do
              fundraiser = create :fundraiser, {
                pledge_start_time: DateTime.now - 1.day,
                pledge_end_time: DateTime.now + 3.day
              }
              event = create :event, {
                fundraiser: fundraiser,
                start_time: DateTime.now - 6.hours,
                end_time: DateTime.now - 2.hours
              }
              team = create :team, event: event

              expect {
                post :create, pledge: {
                  team_id: team.id,
                  amount: 10,
                  monthly: true,
                  anonymous: true
                }
              }.to_not change{ Pledge.count }

              expect(response).to redirect_to event
            end
          end
        end

        describe "when invalid attributes are provided" do
          it "rerenders the edit form" do
            team = create :team

            expect {
              post :create, pledge: {
                team_id: team.id,
                amount: nil
              }
            }.to_not change{ Pledge.count }
            expect(response).to render_template :new
          end

          it "does not error due to garbage parameters" do
            expect {
              post :create, foo: 123
            }.to_not change{ Pledge.count }
            expect(response).to redirect_to organizations_path
          end
        end
      end

      describe "when associated team is not found" do
        it "redirect to orgs index" do
          expect {
            post :create, pledge: {
              team_id: -1,
              amount: 10
            }
          }.to_not change{ Pledge.count }
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        expect {
          post :create, pledge: {
            team_id: 1,
            amount: 10
          }
        }.to_not change{ Pledge.count }
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Show Action ========

  describe "GET show" do
    it "should not be routable" do
      pledge = create :pledge
      expect(:get => '/pledges/#{pledge.id}').not_to be_routable
    end

#    describe "when user is logged in" do
#      before :each do
#        @current_user = create :user
#        sign_in @current_user
#      end
#
#      describe "when requested record is found" do
#        # TODO: Add check that only donor and org members can view pledges.
#        it "renders the show template" do
#          pledge = create :pledge
#          get :show, id: pledge.id
#
#          expect(response).to render_template :show
#          expect(assigns(:pledge)).to eq pledge
#        end
#      end
#
#      describe "when requested record is not found" do
#        it "redirects to orgs index" do
#          get :show, id: -1
#          expect(response).to redirect_to organizations_path
#        end
#      end
#    end
#
#    describe "when user is not logged in" do
#      it "redirects to home page" do
#        get :show, id: -1
#        expect(response).to redirect_to user_session_path
#      end
#    end
  end


  # ======== Edit Action ========

  describe "GET edit" do
    it "should not be routable" do
      pledge = create :pledge
      expect(:get => '/pledges/#{pledge.id}/edit').not_to be_routable
    end
  end


  # ======== Update Action ========

  describe "PUT update" do
    it "should not be routable" do
      pledge = create :pledge
      expect(:put => '/pledges/#{pledge.id}').not_to be_routable
    end
  end


  # ======== Destroy Action ========

  describe "DELETE destroy" do
    it "should not be routable" do
      pledge = create :pledge
      expect(:destroy => '/pledges/#{pledge.id}').not_to be_routable
    end
  end

end
