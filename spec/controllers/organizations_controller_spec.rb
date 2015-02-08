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
        get :index
        expect(response).to render_template :index
      end
    end

    describe "when not logged in" do
      it "redirects to sign up" do
        get :index
        expect(response).to redirect_to user_session_path
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
      end

      describe "when the request succeeds" do
        it "creates a new record" do
          expect {
            post :create, organization: {
              name: 'Test Organization',
              description: 'A test organization.',
              url_key: 'test-org',
              homepage_url: 'http://www.test-org.com/',
              donation_url: 'http://www.test-org.com/donate/'
            }
          }.to change{ Organization.count }.by 1

          org = Organization.find_by_url_key 'test-org'
          expect(org).to_not be_nil

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
    it "renders the show template" do
      org = create :org
      get :show, id: org.id

      expect(response).to render_template :show
      expect(assigns(:org)).to eq org
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

      describe "when the update succeeds" do
        it "updates the organization" do
          org = create :org
          newName = 'New Org Name'
          expect(org.name).to_not eq newName

          put :update, id: org.id, organization: {name: newName}

          newOrg = Organization.find org.id
          expect(newOrg.name).to eq newName
          expect(response).to redirect_to organization_path(org.id)
        end
      end

      describe "when the update fails" do
        it "rerenders the edit template" do
          org = create :org

          put :update, id: org.id, organization: {name: nil}

          expect(response).to render_template :edit
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
end
