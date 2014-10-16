require "rails_helper"

RSpec.describe OrganizationsController do
  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET new" do
    it "renders the new template" do
      @current_user = create(:user)
      sign_in @current_user

      get :new
      expect(response).to render_template("new")
    end
  end
end
