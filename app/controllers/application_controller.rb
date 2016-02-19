class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  include ValidationHelper

  # Returns a list of all top level routing keywords that are reserved for use by the
  # application (i.e. these cannos be used as a org URL key).
  def self.reserved_routing_keywords
    %w(tour about privacy users organizations fundraisers events teams pledges)
  end

  def after_sign_in_path_for(resource)
    # Check for an explicit redirect directive.
    if !params[:redirect].blank?
      redirect_path = params[:redirect].gsub(/^\//, "")
      path = Rails.application.routes.recognize_path("/#{redirect_path}",
                                                     :method => :get) rescue nil
      if path
        return "/#{redirect_path}"
      end
    end

    # Return to the referer if not the sign in page.
    sign_in_url = new_user_session_url
    referer_url = request.referer
    if referer_url == sign_in_url
      super
    else
      stored_location_for(resource) ||
        referer_url ||
        root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    if request.referer.blank?
      super
    else
      request.referer
    end
  end
end
