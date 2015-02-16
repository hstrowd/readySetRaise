require "rails_helper"

RSpec.describe Devise::ConfirmationsController do
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
    describe 'when provided email is recognized' do
      it 'sends an email' do
        user = create :user

        ActionMailer::Base.deliveries.clear
        post :create, user: { email: user.email }

        expect(ActionMailer::Base.deliveries.count).to eq 1
        email = ActionMailer::Base.deliveries[0]
        expect(email.to.count).to eq 1
        expect(email.to[0]).to eq user.email
      end
    end

    describe 'when provided email is not recognized' do
      it 'does not send an email' do
        ActionMailer::Base.deliveries.clear
        post :create, user: { email: 'foo@example.com' }

        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end
  end


  # ======== Show Action ========

  describe "GET show" do
    describe 'when confirmation code is recognized' do
      it 'confirms the associated user' do
        user = create :user

        # Lookup token from confirmation email
        expect(ActionMailer::Base.deliveries.count).to eq 1
        email = ActionMailer::Base.deliveries[0]
        expect(email.to.count).to eq 1
        expect(email.to[0]).to eq user.email

        confirmation_token_match = email.body.parts[1].body.match(/<a href="http.*\?confirmation_token=(.*)">/)
        expect(confirmation_token_match).to_not be_nil
        expect(confirmation_token_match[1]).to_not be_nil

        expect(user.confirmed?).to eq false

        get :show, confirmation_token: confirmation_token_match[1]

        expect(response).to redirect_to new_user_session_path

        user = User.find user.id
        expect(user.confirmed?).to eq true
      end
    end

    describe 'when confirmation code is not recognized' do
      it 'displays the new form' do
        get :show, confirmation_token: 'foo'

        expect(response).to render_template 'devise/confirmations/new'
      end
    end
  end


end
