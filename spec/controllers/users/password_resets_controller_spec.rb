require "rails_helper"

RSpec.describe Users::PasswordResetsController, type: :controller do
  include TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'GET new' do
    it 'renders the new templace' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST create' do
    before :each do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    after :each do
      ActionMailer::Base.deliveries.clear
    end

    describe 'when the provided email is found' do
      it 'renders the new templace' do
        user = create :user

        post :create, user: { email: 'abc@foo.com' }

        expect(response).to redirect_to new_user_session_path
        # I cannot assert that the email was sent because it appears to
        # use a deliver_later call.
      end
    end

    describe 'when the provided email is not found' do
      it 'renders the new templace' do
        email = 'abc@foo.com'

        post :create, user: { email: email }

        # Does the same thing as a success to give potential attackers no
        # information about acounts registered in the system.
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET edit' do
    pending 'implement password reset completion'
  end
end
