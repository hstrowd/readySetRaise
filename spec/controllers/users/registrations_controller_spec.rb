require "rails_helper"

RSpec.describe Users::RegistrationsController do
  include TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end


  # ======== New Action ========

  describe "GET new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template :new
    end
  end


  # ======== Create Action ========

  describe "POST create" do
    describe "when valid attributes are provided" do
      it "creates a new user" do
        first_name = 'User'
        last_name = 'Test'
        email = generate_random_string + '@gmail.com'

        expect(User.find_by_email(email)).to be_nil

        ActionMailer::Base.deliveries.clear
        post :create, user: {
          first_name: first_name,
          last_name: last_name,
          email: email,
          password: 'test1234',
          password_confirmation: 'test1234'
        }

        # Creates the user account.
        new_user = User.find_by_email(email)
        expect(new_user).not_to be_nil
        expect(new_user.first_name).to eq first_name
        expect(new_user.last_name).to eq last_name
        expect(new_user.email).to eq email

        # Sends a confirmation email
        expect(ActionMailer::Base.deliveries.count).to eq 1
        confirm_email = ActionMailer::Base.deliveries[0]
        expect(confirm_email.to.count).to eq 1
        expect(confirm_email.to[0]).to eq new_user.email

        # Automatically logs in as the new user.
        expect(subject.current_user.email).to eq email

        # Redirects to homepage if no action is specified for the session.
        expect(response).to redirect_to root_url
      end

      describe 'when a post signup action is specified' do
        describe 'when the post signup action is new org' do
          it 'redirects to the new org form' do
            first_name = 'User'
            last_name = 'Test'
            email = generate_random_string + '@gmail.com'

            subject.session[:post_signup_action] = :new_org

            post :create, user: {
              first_name: first_name,
              last_name: last_name,
              email: email,
              password: 'test1234',
              password_confirmation: 'test1234'
            }

            expect(response).to redirect_to new_organization_path
          end
        end
      end
    end

    describe "when invalid attributes are provided" do
      it "rerenders the new template" do
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
  end


  # ======== Show Action ========

  describe "GET show" do
    it "should not be routable" do
      user = create :user
      expect(:show => '/users/#{user.id}').not_to be_routable
    end

#    describe "when logged in" do
#      before :each do
#        @current_user = create :user
#        sign_in @current_user
#      end
#
#      describe "when requesting current user's account" do
#        it "renders show template" do
#          get :show, id: @current_user.id
#          expect(response).to render_template :show
#        end
#      end
#
#      describe "when requesting account other than current user's" do
#        before :each do
#          @requested_user = create :user
#        end
#
#        it "redirects to current user's account" do
#          get :show, id: @requested_user.id
#          expect(response).to redirect_to show_user_path(@current_user)
#        end
#      end
#    end
#
#    describe "when not logged in" do
#      it "redirects to sign in form" do
#        get :show, id: 1
#        expect(response).to redirect_to new_user_session_path
#      end
#    end
  end


  # ======== Edit Action ========

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


  # ======== Update Action ========

  describe "PUT update" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "when valid attributes are provided" do
        it "modifies the current user's account" do
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

          expect(response).to redirect_to root_url
        end
      end

      describe "when invalid attributes are provided" do
        it "rerenders the edit template" do
          put :update, user: {
            email: nil,
            current_password: 'abcd1234'
          }

          expect(response).to render_template :edit
        end
      end

      describe "when the improper current password is specified" do
        it "rerenders the edit template" do
          new_first_name = 'Test'
          new_last_name = 'User'

          put :update, user: {
            first_name: new_first_name,
            last_name: new_last_name,
            current_password: 'abcd4321'
          }

          expect(response).to render_template :edit
        end
      end

      describe "when a new password is specified" do
        describe "when the new password and confirmation don't match" do
          it "rerenders the edit template" do
            put :update, user: {
              password: 'abcd12345',
              password_confirmation: 'zyxw54321',
              current_password: 'abcd1234'
            }

            updated_user = User.find @current_user.id
            expect(updated_user.encrypted_password).to eq @current_user.encrypted_password

            expect(response).to render_template :edit
          end
        end

        describe "when the new password and confirmation match" do
          it "updates the user's password" do
            put :update, user: {
              password: 'abcd12345',
              password_confirmation: 'abcd12345',
              current_password: 'abcd1234'
            }

            updated_user = User.find @current_user.id
            expect(updated_user.encrypted_password).to_not eq @current_user.encrypted_password

            expect(response).to redirect_to root_url
          end
        end
      end

      describe "when a new email is specified" do
        it "updates the user's email and sends a new confirmation email" do
          ActionMailer::Base.deliveries.clear
          put :update, user: {
            email: 'new@email.com',
            current_password: 'abcd1234'
          }

          updated_user = User.find @current_user.id
          expect(updated_user.email).to eq @current_user.email
          expect(updated_user.unconfirmed_email).to eq 'new@email.com'

          # Sends a confirmation to the new email
          expect(ActionMailer::Base.deliveries.count).to eq 1
          confirm_email = ActionMailer::Base.deliveries[0]
          expect(confirm_email.to.count).to eq 1
          expect(confirm_email.to[0]).to eq updated_user.unconfirmed_email

          expect(response).to redirect_to root_url
        end
      end
    end

    describe "when not logged in" do
      it "redirects to the login page" do
        put :update
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ======== Destroy Action ========

  describe "DELETE destroy" do
    describe "when logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      it "deletes the current user's record" do
        delete :destroy

        updated_user = User.find_by_email @current_user.email
        expect(updated_user).to be_nil

        # Immediately logged out
        expect(subject.current_user).to be_nil

        expect(response).to redirect_to root_url
      end
    end

    describe "when not logged in" do
      it "redirects to the login page" do
        delete :destroy
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
