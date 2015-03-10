# NOTE: This class is not currently being used. To enable it, update the routes config to add it to the users scope.
class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    if !params[:redirect].blank?
      redirect_path = params[:redirect].gsub(/^\//, "")
      path = Rails.application.routes.recognize_path("/#{redirect_path}", :method => :get) rescue nil
      if path
        store_location_for(:user, "/#{redirect_path}")
      else
        logger.warn("Unrecognized post-authentication path: #{redirect_path}")
      end
    end

    super
  end

  # POST /resource/sign_in
  def create
    logger.info("attempting sign in")
    if !params[:redirect].blank?
      logger.info("found redirect param: #{params[:redirect]}")
      redirect_path = params[:redirect].gsub(/^\//, "")
      path = Rails.application.routes.recognize_path("/#{redirect_path}", :method => :get) rescue nil
      if path
        logger.info("setting location: #{redirect_path}")
        store_location_for(:user, "/#{redirect_path}")
      else
        logger.warn("Unrecognized post-authentication path: #{redirect_path}")
      end
    end

    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
