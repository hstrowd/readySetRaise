class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]

  # GET /resource/:id
  # def show
  #   if !current_user
  #     redirect_to new_user_session_path
  #     return
  #   end
  #
  #   if(current_user.id != params[:id].to_i)
  #     flash[:alert] = 'Invalid Request'
  #     redirect_to action: :show, id: current_user.id
  #     return
  #   end
  #
  #   @user = current_user
  #   @orgs = current_user.organizations
  # end

  # GET /resource/sign_up
  def new
    # TODO: If we're already logged in and a redirect was requested,
    # attempt to redirect immediately.
    super

    if params[:redirect]
      path = Rails.application.routes.recognize_path("/#{params[:redirect]}", :method => :get) rescue nil
      if path
        session[:post_signup_path] = "/#{params[:redirect]}"
      else
        logger.warn("Unrecognized post-signup path: #{params[:redirect]}")
      end
    end
  end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # You can put the params you want to permit in the empty array.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :first_name << :last_name << :phone_number
  end

  # You can put the params you want to permit in the empty array.
  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) << :first_name << :last_name << :phone_number
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    if session[:post_signup_path]
      return session[:post_signup_path]
    else
      return root_path
    end
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
