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
        expect(response).to render_template :new
      end
    end

    describe "when logged in" do
      before :each do
        @current_user = create :user
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
      describe "when proper credentials are provided" do
        describe "when the account requires confirmation" do
          pending "rejects the request" do
            user = create :user

            #expect(user.active_for_authentication?).to eq false

            # Note: This cannot be set as part of the create because it gets overwritten.
            user.confirmation_sent_at = (DateTime.now - 3.months)
            user.save!

            #expect(user.active_for_authentication?).to eq true

            post :create, user: {
              email: user.email,
              password: 'abcd1234'
            }

            # binding.pry

            expect(subject.current_user).to be_nil
            expect(response).to render_template :new
          end
        end

        describe "when the account has been confirmed" do
          it "logs the user in" do
            user = create :user
            post :create, user: {
              email: user.email,
              password: 'abcd1234'
            }

            expect(subject.current_user).to_not be_nil
            expect(subject.current_user.email).to eq user.email
          end
        end
      end

      describe "when invalid credentials are provided" do
        it "rejects improper passwords" do
          user = create :user
          post :create, user: {
            email: user.email,
            password: 'abcd12345'
          }

          expect(subject.current_user).to be_nil
          expect(response).to render_template :new
        end

        it "rejects unknown email" do
          post :create, user: {
            email: 'foo@example.com',
            password: 'abcd12345'
          }

          expect(subject.current_user).to be_nil
          expect(response).to render_template :new
        end
      end
    end

    describe "when logged in" do
      before :each do
        @current_user = create :user
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
        @current_user = create :user
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
        expect(response).to redirect_to root_url
      end
    end
  end
end
