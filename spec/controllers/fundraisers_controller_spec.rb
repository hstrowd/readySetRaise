require 'rails_helper'

RSpec.describe FundraisersController, :type => :controller do

  describe "GET new" do
    render_views

    it "renders the new template" do
#      expect(assigns(:fundraiser)).to be_a_new(Fundraiser)
#      expect(response).to render_template(:new)
    end

    it "redirects to new org form for users without an associated org"
      current_user = create(:user)
      sign_in current_user

      expect(current_user.organizations).to be_empty

      get :new

      expect(response).to redirect_to new_organization_path
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
      current_user = create(:user)
      sign_in current_user

      org = create(:org)
      expect {
        post :create, fundraiser: {
          title: nil,
          description: 'A test fundraiser.',
          organization_id: org.id,
          pledge_start_time: '2014-10-10T18:19:20Z',
          pledge_end_time: '2014-10-10T18:19:20Z'
        }
      }.to_not change{ Fundraiser.count}

      expect(response).to render_template(:new)
      expect(assigns(:org).errors.count).to be > 0
    end

    it "creates a new record" do
      current_user = create(:user)
      sign_in current_user

      org = create(:org)
      expect {
        post :create, fundraiser: {
          title: 'Test Fundraiser',
          description: 'A test fundraiser.',
          organization_id: org.id,
          pledge_start_time: '2014-10-10T18:19:20Z',
          pledge_end_time: '2014-10-10T18:19:20Z'
        }
      }.to change{ Fundraiser.count }.by(1)
    end

    ## Test an invalid date format.
  end

end
