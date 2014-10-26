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
      @current_user = create(:user)
      sign_in @current_user

      get :new
      expect(response).to render_template("new")
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
      @current_user = create(:user)
      sign_in @current_user

      # TODO: Look into other ways of accomplishing this.
      expect(Organization.find_by_name('Test Organization')).to be_nil

      post :create, organization: {
        name: nil,
        description: 'A test organization.',
        url_key: 'test-org',
        homepage_url: 'http://www.test-org.com/',
        donation_url: 'http://www.test-org.com/donate/'
      }
      expect(response).to render_template('new')

      # TODO: figure out how to assert this.
      #expect(subject.org.errors.count).to be_gt(0)

      expect(Organization.find_by_name('Test Organization')).to be_nil
    end

    it "creates a new record" do
      @current_user = create(:user)
      sign_in @current_user

      # TODO: Look into other ways of accomplishing this.
      expect(Organization.find_by_name('Test Organization')).to be_nil

      post :create, organization: {
        name: 'Test Organization',
        description: 'A test organization.',
        url_key: 'test-org',
        homepage_url: 'http://www.test-org.com/',
        donation_url: 'http://www.test-org.com/donate/'
      }
      expect(response).to redirect_to new_fundraiser_path

      expect(Organization.find_by_name('Test Organization')).to_not be_nil
    end
  end
end
