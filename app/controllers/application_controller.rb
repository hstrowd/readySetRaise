class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  include ValidationHelper

  # Returns a list of all top level routing keywords that are reserved for use by the
  # application (i.e. these cannos be used as a org URL key).
  def self.reserved_routing_keywords
    %w(tour about users organizations fundraisers events teams pledges)
  end
end
