require "rails_helper"

RSpec.describe Users::RegistrationsController do
  include TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "POST create" do
    it "redirects the user to the home page" do
      first_name = 'User'
      last_name = 'Test'
      email = generate_random_string + '@gmail.com'

      post :create, user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: 'test1234',
        password_confirmation: 'test1234'
      }

      expect(response).to redirect_to root_url
    end

    it "creates a new user" do
      first_name = 'User'
      last_name = 'Test'
      email = generate_random_string + '@gmail.com'

      expect(User.find_by_email(email)).to be_nil

      post :create, user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: 'test1234',
        password_confirmation: 'test1234'
      }

      new_user = User.find_by_email(email)
      expect(new_user).not_to be_nil
      expect(new_user.first_name).to eq first_name
      expect(new_user.last_name).to eq last_name
      expect(new_user.email).to eq email
    end

    it "logs in as the new user" do
      first_name = 'User'
      last_name = 'Test'
      email = generate_random_string + '@gmail.com'

      post :create, user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: 'test1234',
        password_confirmation: 'test1234'
      }

      expect(subject.current_user.email).to eq email
    end

    it "rerenders the new template if request fails" do
      existingUser = create :user
      first_name = 'User'
      last_name = 'Test'

      post :create, user: {
        first_name: first_name,
        last_name: last_name,
        email: existingUser.email,
        password: 'test1234',
        password_confirmation: 'test1234'
      }

      expect(response).to render_template :new
      expect(assigns(:user).email).to eq existingUser.email
      # Don't pass back the password to ensure proper security.
      expect(assigns(:user).password).to be_nil
    end
  end

  describe "GET edit" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      it "renders the edit template" do
        get :edit
        expect(response).to render_template :edit
        expect(assigns(:user)).to eq @current_user
      end
    end

    describe "when not logged in" do
      it "redirects to the login page" do
        get :edit
        expect(response).to redirect_to user_session_path
      end
    end
  end

  describe "PUT update" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      it "redirects to the home page" do
        new_first_name = 'Test'
        new_last_name = 'User'

        put :update, user: {
          first_name: new_first_name,
          last_name: new_last_name,
          phone_number: '',
          email: @current_user.email,
          password: '',
          password_confirmation: '',
          current_password: 'abcd1234'
        }

        expect(response).to redirect_to root_url
      end

      it "updates the current user's attributes" do
        new_first_name = 'Test'
        new_last_name = 'User'

        expect(@current_user.first_name).to_not eq new_first_name
        expect(@current_user.last_name).to_not eq new_last_name

        put :update, user: {
          first_name: new_first_name,
          last_name: new_last_name,
          phone_number: '',
          email: @current_user.email,
          password: '',
          password_confirmation: '',
          current_password: 'abcd1234'
        }

        updated_user = User.find_by_id(@current_user.id)

        expect(updated_user.email).to eq @current_user.email
        expect(updated_user.first_name).to eq new_first_name
        expect(updated_user.last_name).to eq new_last_name
      end
    end

    describe "when not logged in" do
      it "redirects to the login page" do
        put :update
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE destroy" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      it "redirects to the home page" do
        delete :destroy
        expect(response).to redirect_to root_url
      end

      it "deletes the current user's record" do
        delete :destroy

        updated_user = User.find_by_email @current_user.email
        expect(updated_user).to be_nil
      end

      it "logs out the current user" do
        delete :destroy

        expect(subject.current_user).to be_nil
      end
    end

    describe "when not logged in" do
      it "redirects to the login page" do
        put :destroy
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
