require 'rails_helper'

RSpec.describe TeamsController, :type => :controller do
  render_views

  # ======== Index Action ========

  describe "GET index" do
    it "should not be routable" do
      expect(:get => '/teams').not_to be_routable
    end
  end


  # ======== New Action ========

  describe "GET new" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when associated event is found" do
        before :each do
          @event = create :event
        end

        describe "when current user is member of org" do
          it "renders the new template" do
            @event.fundraiser.organization.members << @current_user

            get :new, event_id: @event.id

            expect(response).to render_template :new
          end
        end

        describe "when current user is not member of org" do
          it "redirects to orgs index" do
            get :new, event_id: @event.id
            expect(response).to redirect_to organizations_path
          end
        end
      end

      describe "when associated event is not found" do
        it "redirects to orgs index" do
          get :new, event_id: -1
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        get :new, event_id: 1
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

      describe "when associated event is found" do
        before :each do
          @event = create :event
        end

        describe "when the current user is member of org" do
          before :each do
            @event.fundraiser.organization.members << @current_user
          end

          describe "when valid attributes are provided" do
            it "creates a new event" do
              expect {
                post :create, team: {
                  name: 'Test Team 1',
                  pledge_target: 150,
                  event_id: @event.id
                }
              }.to change{ Team.count }.by 1

              expect(response).to redirect_to @event
            end
          end

          describe "when invalid attributes are provided" do
            it "rerenders the edit form" do
              expect {
                post :create, team: {
                  name: nil,
                  pledge_target: 150,
                  event_id: @event.id
                }
              }.to_not change{ Team.count }

              expect(response).to render_template :new
            end

            it "does not error due to garbage parameters" do
              expect {
                post :create, foo: 123
              }.to_not change{ Team.count }

              expect(response).to redirect_to organizations_path
            end
          end
        end

        describe "when the current user is not member of org" do
          it "redirect to orgs index" do
            expect {
              post :create, team: {
                name: 'Test Team 1',
                pledge_target: 150,
                event_id: @event.id
              }
            }.to_not change{ Team.count }
            expect(response).to redirect_to organizations_path
          end
        end
      end

      describe "when associated event is not found" do
        it "redirect to orgs index" do
          expect {
            post :create, team: {
              name: 'Test Team 1',
              pledge_target: 150,
              event_id: -1
            }
          }.to_not change{ Team.count }
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        expect {
          post :create, team: {
            name: 'Test Team 1',
            pledge_target: 150,
            event_id: 1
          }
        }.to_not change{ Team.count }
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Show Action ========

  describe "GET show" do
    describe "when requested record is found" do
      it "renders the show template" do
        team = create :team
        get :show, id: team.id

        expect(response).to render_template :show
        expect(assigns(:team)).to eq team
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
          team = create :team
          get :edit, id: team.id
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
          @team = create :team
        end

        describe "when record update succeeds" do
          it "modifies and shows the record" do
            newName = "New Team 1"
            expect(@team.name).to_not eq newName

            put :update, id: @team.id, team: { name: newName}

            expect(Team.find(@team.id).name).to eq newName
            expect(response).to redirect_to team_path(@team)
          end
        end

        describe "when record upadte fails" do
          it "rerenders the edit form" do
            put :update, id: @team.id, team: { name: nil}
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
      team = create :team
      expect(:destroy => '/teams/#{team.id}').not_to be_routable
    end
  end

end
