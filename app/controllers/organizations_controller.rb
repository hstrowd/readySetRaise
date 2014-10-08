class OrganizationsController < ApplicationController

  def index
    @orgs = Organization.all
  end

  # TODO: Require users to be logged in.
  def create

  end

end
