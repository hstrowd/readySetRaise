require "rails_helper"

RSpec.describe Users::PasswordResetsController, type: :controller do
  include TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end


  # ======== New Action ========

  describe 'GET new' do
    it 'renders the new templace' do
      get :new
      expect(response).to render_template :new
    end
  end


  # ======== Create Action ========

  describe 'POST create' do
    describe 'when the provided email is found' do
      it 'sends user an email' do
        user = create :user

        ActionMailer::Base.deliveries.clear
        post :create, user: { email: user.email }

        expect(ActionMailer::Base.deliveries.count).to eq 1
        email = ActionMailer::Base.deliveries[0]
        expect(email.to.count).to eq 1
        expect(email.to[0]).to eq user.email

        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'when the provided email is not found' do
      it 'renders the new templace' do
        email = 'abc@foo.com'

        post :create, user: { email: 'abc@foo.com' }

        # Does the same thing as a success to give potential attackers no
        # information about acounts registered in the system.
        expect(response).to redirect_to new_user_session_path
      end
    end
  end


  # ======== Edit Action ========

  describe 'GET edit' do
    before :each do
      @user = create :user

      ActionMailer::Base.deliveries.clear
      post :create, user: { email: @user.email }

      expect(ActionMailer::Base.deliveries.count).to eq 1
      @email = ActionMailer::Base.deliveries[0]

      token_match = @email.body.parts[1].body.match(/<a href="http.*\?reset_password_token=(.*)">/)
      expect(token_match).to_not be_nil

      @token = token_match[1]
      expect(@token).to_not be_nil
    end

    describe 'when no token is provided' do
      it 'redirects to the login form' do
        get :edit

        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'when the token is recognized' do
      it 'displays the change password form' do
        get :edit, reset_password_token: @token

        expect(response).to render_template :edit
      end
    end

    describe 'when the token is not recognized' do
      it 'displays the change password form' do
        get :edit, reset_password_token: 'foo'

        expect(response).to render_template :edit
      end
    end
  end


  # ======== Update Action ========


  describe 'PUT update' do
    before :each do
      @user = create :user

      ActionMailer::Base.deliveries.clear
      post :create, user: { email: @user.email }

      expect(ActionMailer::Base.deliveries.count).to eq 1
      @email = ActionMailer::Base.deliveries[0]

      token_match = @email.body.parts[1].body.match(/<a href="http.*\?reset_password_token=(.*)">/)
      expect(token_match).to_not be_nil

      @token = token_match[1]
      expect(@token).to_not be_nil
    end

    describe 'when the token is recognized' do
      it 'updates the associated user\s password' do
        new_password = 'testPassword'
        put :update, user: {
          reset_password_token: @token,
          password: new_password,
          password_confirmation: new_password
        }

        user = User.find @user.id
        expect(subject.current_user).to_not be_nil
        expect(subject.current_user).to eq user

        expect(user.valid_password?(new_password)).to eq true

        expect(response).to redirect_to root_path
      end
    end

    describe 'when the token is recognized' do
      it 'makes no password changes' do
        put :update, user: {
          reset_password_token: 'foo',
          password: 'testPassword',
          password_confirmation: 'testPassword'
        }

        expect(response).to render_template :edit
      end
    end
  end

end
