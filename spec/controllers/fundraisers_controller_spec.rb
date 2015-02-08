require 'rails_helper'

RSpec.describe FundraisersController, :type => :controller do
  render_views


  # ======== New Action ========

  describe "GET new" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when current user is a member of no orgs" do
        it "redirects to new org form" do
          expect(@current_user.organizations).to be_empty

          get :new, organization_id: -1

          expect(response).to redirect_to new_organization_path
        end
      end

      describe "when current user is a member of at least one org" do
        before :each do
          @org = create :org, creator: @current_user
        end

        it "renders the new template for valid org requests" do
          get :new, organization_id: @org.id

          expect(assigns(:organizations)).to eq @current_user.organizations
          expect(assigns(:fundraiser)).to be_a_new Fundraiser
          expect(response).to render_template :new
        end

        it "redirects to organization index for invalid requested org" do
          get :new, organization_id: -1

          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        # This org ID does not need to exist because the user is not
        # logged in and therefore it will never be checked.
        get :new, organization_id: 0
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

      describe "when a valid org is specified" do
        before :each do
          @org = create :org
        end

        describe "when the current user is not a member the org" do
          it 'redirects to the new org form' do
            expect(@current_user.organizations).to be_empty

            expect {
              post :create, fundraiser: {
                title: nil,
                description: 'A test fundraiser.',
                organization_id: @org.id,
                pledge_start_time: DateTime.now.iso8601,
                pledge_end_time: (DateTime.now + 3.days).iso8601
              },
              organization_id: @org.id
            }.to_not change{ Fundraiser.count }

            expect(response).to redirect_to organizations_path
          end
        end

        describe "when the current user is a member of the org" do
          before :each do
            @org.members << @current_user
            @org.save!
          end

          describe "when the request is valid" do
            it 'creates a new record' do
              expect {
                post :create, fundraiser: {
                  title: 'Test Fundraiser',
                  description: 'A test fundraiser.',
                  organization_id: @org.id,
                  pledge_start_time: DateTime.now.iso8601,
                  pledge_end_time: (DateTime.now + 3.days).iso8601
                },
                organization_id: @org.id
              }.to change{ Fundraiser.count }.by 1

              expect(response).to redirect_to new_fundraiser_event_path(Fundraiser.last)
            end
          end

          describe "when the request is invalid" do
            it 'rerenders the new fundraiser form' do
              expect {
                post :create, fundraiser: {
                  title: nil,
                  description: 'A test fundraiser.',
                  organization_id: @org.id,
                  pledge_start_time: DateTime.now.iso8601,
                  pledge_end_time: (DateTime.now + 3.days).iso8601
                },
                organization_id: @org.id
              }.to_not change{ Fundraiser.count}

              expect(response).to render_template :new
              expect(assigns(:fundraiser).errors.count).to be > 0
            end

            it "does not error due to garbage parameters" do
              expect {
                post :create, foo: 123
              }.to_not change{ Fundraiser.count }

              expect(response).to redirect_to organizations_path
            end
          end
        end
      end

      describe "when an invalid org is specified" do
        it 'redirects to the org index' do
            expect {
              post :create, fundraiser: {
                title: 'Test Fundraiser',
                description: 'A test fundraiser.',
                organization_id: -1,
                pledge_start_time: DateTime.now.iso8601,
                pledge_end_time: (DateTime.now + 3.days).iso8601
              },
              organization_id: -1
            }.to_not change{ Fundraiser.count}

          expect(response).to redirect_to organizations_path
        end
      end

      ## TODO: Test an invalid date format.
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        # This org ID does not need to exist because the user is not
        # logged in and therefore it will never be checked.
        post :create, organization_id: 0
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Show Action ========

  describe 'GET show' do
    describe "when requested record is found" do
      it "renders the new template" do
        fundraiser = create :fundraiser
        get :show, id: fundraiser.id

        expect(response).to render_template :show
        expect(assigns(:fundraiser)).to eq fundraiser
      end
    end

    describe "when requested record is not found" do
      describe "when user is not logged in" do
        it "redirects to home page" do
          get :show, id: -1

          expect(response).to redirect_to root_url
        end
      end

      describe "user is logged in" do
        it "redirects to organization index" do
          sign_in create :user

          get :show, id: -1

          expect(response).to redirect_to organizations_path
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
          fundraiser = create :fundraiser
          get :edit, id: fundraiser.id
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
        get :edit, id: 1
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
          @fundraiser = create :fundraiser
        end

        describe "when record update succeeds" do
          it "modify and show the record" do
            newTitle = "New Fundraiser Title"
            expect(@fundraiser.title).to_not eq newTitle

            put :update, id: @fundraiser.id, fundraiser: { title: newTitle}

            expect(Fundraiser.find(@fundraiser.id).title).to eq newTitle
            expect(response).to redirect_to fundraiser_path(@fundraiser)
          end
        end

        describe "when record upadte fails" do
          it "rerenders the edit form" do
            put :update, id: @fundraiser.id, fundraiser: { title: nil}
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
        put :update, id: 1
        expect(response).to redirect_to user_session_path
      end
    end
  end
end
