require "rails_helper"

RSpec.describe Devise::SessionsController do
  include TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET new" do
    describe "when not logged in" do
      it "renders the new template" do
        get :new
        expect(response).to render_template("new")
      end
    end

    describe "when logged in" do
      before :each do
        @current_user = create(:user)
        sign_in @current_user
      end

      it "redirects to the root_url" do
        get :new
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "POST create" do
    describe "when not logged in" do
      it "logs the user in" do
        user = create(:user)
        post :create, user: {
          email: user.email,
          password: 'abcd1234'
        }

        expect(subject.current_user.email).to eq user.email
      end

      it "rejects improper passwords" do
        user = create(:user)
        post :create, user: {
          email: user.email,
          password: 'abcd12345'
        }

        expect(subject.current_user).to be_nil
      end
    end

    describe "when logged in" do
      before :each do
        @current_user = create(:user)
        sign_in @current_user
      end

      it "redirects to the root_url" do
        get :new
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "DELETE destroy" do
    describe "when logged in" do
      before :each do
        @current_user = create(:user)
        sign_in @current_user
      end

      it "redirects to the home page" do
        delete :destroy
        expect(response).to redirect_to root_url
      end

      it "logs out the current user" do
        delete :destroy

        expect(subject.current_user).to be_nil
      end
    end

    describe "when not logged in" do
      it "redirects to the home page" do
        put :destroy
        # TODO: Find a more maintainable way to assert this redirect location.
        expect(response).to redirect_to root_url
      end
    end
  end
end
