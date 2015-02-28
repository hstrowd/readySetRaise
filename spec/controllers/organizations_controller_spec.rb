require "rails_helper"

RSpec.describe OrganizationsController do

  # ======== Index Action ========

  describe "GET index" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      it "renders the index template" do
        org1 = create :org
        org1.members << @current_user
        org2 = create :org

        get :index

        expect(response).to render_template :index

        # Only show the current user's organizations.
        orgs = assigns(:orgs)
        expect(orgs).not_to be_nil
        expect(orgs.count).to eq 1
        expect(orgs.include?(org1)).to eq true
        expect(orgs.include?(org2)).to eq false
      end
    end

    describe "when not logged in" do
      it "redirects to sign in" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
  end


  # ======== New Action ========

  describe "GET new" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      it "renders the new template" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        get :new
        expect(response).to redirect_to new_user_registration_path

        # Marks the session to redirect to new org after sign-up.
        expect(subject.session[:post_signup_action]).to eq :new_org
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

      describe "when the request fails" do
        it "re-renders the new record form" do
          description = 'A test organization.'
          expect {
            post :create, organization: {
              name: nil,
              description: description,
              url_key: 'test-org',
              homepage_url: 'http://www.test-org.com/',
              donation_url: 'http://www.test-org.com/donate/'
            }
          }.to_not change{ Organization.count }

          expect(response).to render_template :new
          expect(assigns(:org).errors.count).to be > 0
          expect(assigns(:org).description).to eq description
        end

        it "does not throw an error when invalid parameters are provided" do
          expect {
            post :create, foo: 123
          }.to_not change{ Organization.count }

          expect(response).to render_template :new
        end
      end

      describe "when the request succeeds" do
        it "creates a new record" do
          name = 'Test Organization'
          description = 'A test organization.'
          url_key = 'test-org'
          homepage_url = 'http://www.test-org.com/'
          donation_url = 'http://www.test-org.com/donate/'
          logo_url = 'http://www.test-org.com/logo.png'

          expect {
            post :create, organization: {
              name: name,
              description: description,
              url_key: url_key,
              homepage_url: homepage_url,
              donation_url: donation_url,
              logo_url: logo_url
            }
          }.to change{ Organization.count }.by 1

          org = Organization.find_by_url_key 'test-org'
          expect(org).to_not be_nil

          # Allows all attributes to be set.
          expect(org.name).to eq name
          expect(org.description).to eq description
          expect(org.url_key).to eq url_key
          expect(org.homepage_url).to eq homepage_url
          expect(org.donation_url).to eq donation_url
          expect(org.logo_url).to eq logo_url

          expect(response).to redirect_to new_organization_fundraiser_path(org.id)
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        post :create
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Show Action ========

  describe "GET show" do
    describe "when organization is found" do
      before :each do
          @org = create :org
      end

      describe "when the record id is used" do
        it "renders the show template" do
          get :show, id: @org.id

          expect(response).to render_template :show
          expect(assigns(:org)).to eq @org
        end
      end

      describe "when the URL key is used" do
        it "renders the show template" do
          get :show, org_url_key: @org.url_key

          expect(response).to render_template :show
          expect(assigns(:org)).to eq @org
        end
      end

      describe "when both the record id and URL key are used" do
        it "renders the show template based on the record id" do
          org2 = create :org

          get :show, id: @org.id, org_url_key: org2.url_key

          expect(response).to render_template :show
          expect(assigns(:org)).to eq @org
        end
      end
    end

    describe "when organization is not found" do
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

      describe "when request org is found" do
        it "renders the edit template" do
          org = create :org
          get :edit, id: org.id
          expect(response).to render_template :edit
        end
      end

      describe "when request org is not found" do
        it "redirects to orgs index" do
          get :edit, id: -1
          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up form" do
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

      describe "when the specified org is found" do
        before :each do
          @org = create :org
        end

        describe "when the update succeeds" do
          it "updates the organization" do
            newName = 'New Org Name'
            expect(@org.name).to_not eq newName

            put :update, id: @org.id, organization: {name: newName}

            newOrg = Organization.find @org.id
            expect(newOrg.name).to eq newName
            expect(response).to redirect_to organization_path(@org.id)
          end
        end

        describe "when the update fails" do
          it "rerenders the edit template" do
            put :update, id: @org.id, organization: {name: nil}

            expect(response).to render_template :edit
          end

          it "does not error due to garbage parameters" do
            put :update, id: @org.id, foo: 123

            # This actually succeeds because the garbage parameters
            # are ignored so nothing about the organization is changed.
            expect(response).to redirect_to @org
          end
        end
      end

      describe "when the specified org is not found" do
        it "it redirects to orgs index" do
          put :update, id: -1

          expect(response).to redirect_to organizations_path
        end
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        post :create
        expect(response).to redirect_to user_session_path
      end
    end
  end


  # ======== Destroy Action ========

  describe "DELETE destroy" do
    it "should not be routable" do
      org = create :org
      expect(:destroy => '/organizations/#{org.id}').not_to be_routable
    end
  end

end
