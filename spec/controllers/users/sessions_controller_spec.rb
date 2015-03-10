require "rails_helper"

RSpec.describe Users::SessionsController do
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

      describe "when no redirect specified" do
        it "redirects to the root_url" do
          get :new
          expect(response).to redirect_to root_url
        end
      end

      describe "when a redirect is specified" do
        describe "when the redirect is valid" do
          it "redirects to the specified URL" do
            event = create :event
            redirect_path = event_path(event)
            get :new, redirect: redirect_path
            expect(response).to redirect_to redirect_path
          end
        end

        describe "when the redirect is invalid" do
          it "redirects to the root_url" do
            get :new, redirect: "foo/bar/baz"
            expect(response).to redirect_to root_url
          end
        end
      end
    end
  end

  describe "POST create" do
    describe "when not logged in" do
      describe "when proper credentials are provided" do
#        describe "when the account requires confirmation" do
#          it "rejects the request" do
#            user = create :user
#
#            #expect(user.active_for_authentication?).to eq false
#
#            # Note: This cannot be set as part of the create because it gets overwritten.
#            user.confirmation_sent_at = (DateTime.now - 3.months)
#            user.save!
#
#            #expect(user.active_for_authentication?).to eq true
#
#            post :create, user: {
#              email: user.email,
#              password: 'abcd1234'
#            }
#
#            # binding.pry
#
#            expect(subject.current_user).to be_nil
#            expect(response).to render_template :new
#          end
#        end

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

          describe "when a redirect is specified" do
            it "redirects to the specified path" do
              team = create :team
              redirect_path = team_path(team)

              user = create :user
              post :create, {
                redirect: redirect_path,
                user: {
                  email: user.email,
                  password: 'abcd1234'
                }
              }

              expect(response).to redirect_to redirect_path
            end
          end

          describe "when a redirect is not specified" do
            it "redirects to the referer page" do
              team = create :team
              referer_url = team_url(team)

              allow(controller.request).to receive(:referer) { referer_url }

              user = create :user
              post :create, user: {
                email: user.email,
                password: 'abcd1234'
              }

              expect(response).to redirect_to referer_url
            end
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

        describe "when a redirect is specified" do
          it "stores the URL for use once the login is completed" do
            fundraiser = create :fundraiser
            redirect_path = fundraiser_path(fundraiser)

            expect(subject.stored_location_for(:user)).not_to eq redirect_path

            post :create, {
              redirect: redirect_path,
              user: {
                email: 'foo@example.com',
                password: 'abcd12345'
              }
            }

            expect(subject.stored_location_for(:user)).to eq redirect_path
          end
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

      describe "when a referer page is found" do
        it "redirects back to the referer page" do
          org = create :org
          referer_url = organization_url(org)
          allow(controller.request).to receive(:referer) { referer_url }

          delete :destroy
          expect(response).to redirect_to referer_url
        end
      end

      describe "when no referer page is found" do
        it "redirects to the home page" do
          delete :destroy
          expect(response).to redirect_to root_url
        end
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
