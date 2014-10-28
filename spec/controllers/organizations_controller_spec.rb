require "rails_helper"

RSpec.describe OrganizationsController do
  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET new" do
    it "renders the new template" do
      current_user = create(:user)
      sign_in current_user

      get :new

      expect(assigns(:org)).to be_a_new(Organization)
      expect(response).to render_template(:new)
    end

    it "redirects to sign up if user not signed in" do
      get :new
      expect(response).to redirect_to new_user_registration_path
    end
  end

  describe "POST create" do
    it "redirects to sign up if user not signed in" do
      post :create
      expect(response).to redirect_to user_session_path
    end

    it "re-renders the new record form if the submission is invalid" do
      current_user = create(:user)
      sign_in current_user

      expect {
        post :create, organization: {
          name: nil,
          description: 'A test organization.',
          url_key: 'test-org',
          homepage_url: 'http://www.test-org.com/',
          donation_url: 'http://www.test-org.com/donate/'
        }
      }.to_not change{ Organization.count }

      expect(response).to render_template(:new)
      expect(assigns(:org).errors.count).to be > 0
    end

    it "creates a new record" do
      current_user = create(:user)
      sign_in current_user

      expect {
        post :create, organization: {
          name: 'Test Organization',
          description: 'A test organization.',
          url_key: 'test-org',
          homepage_url: 'http://www.test-org.com/',
          donation_url: 'http://www.test-org.com/donate/'
        }
      }.to change{ Organization.count }.by(1)

      expect(response).to redirect_to new_fundraiser_path

    end
  end
end
