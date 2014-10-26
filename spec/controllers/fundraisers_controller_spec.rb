require 'rails_helper'

RSpec.describe FundraisersController, :type => :controller do

  describe "GET new" do
    it "renders the new template" do
      @current_user = create(:user)
      sign_in @current_user

      get :new
      expect(response).to render_template("new")
    end

    it "redirects to sign up if user not signed in" do
      get :new
      expect(response).to redirect_to user_session_path
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
      expect(Fundraiser.find_by_title('Test Fundraiser')).to be_nil

      post :create, fundraiser: {
        title: nil,
        description: 'A test fundraiser.',
        pledge_start_time: '2014-10-10T18:19:20Z',
        pledge_end_time: '2014-10-10T18:19:20Z'
      }
      expect(response).to render_template('new')

      # TODO: figure out how to assert this.
      #expect(subject.org.errors.count).to be_gt(0)

      expect(Fundraiser.find_by_title('Test Fundraiser')).to be_nil
    end

    it "creates a new record" do
      @current_user = create(:user)
      sign_in @current_user

      # TODO: Look into other ways of accomplishing this.
      expect(Fundraiser.find_by_title('Test Fundraiser')).to be_nil

      post :create, fundraiser: {
        title: 'Test Fundraiser',
        description: 'A test fundraiser.',
        pledge_start_time: '2014-10-10T18:19:20Z',
        pledge_end_time: '2014-10-10T18:19:20Z'
      }

      expect(Fundraiser.find_by_title('Test Fundraiser')).to_not be_nil
    end
  end

end
