require "rails_helper"

RSpec.describe HomeController do
  describe "GET root" do
    it "renders the home page" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET about" do
    it "renders the about page" do
      get :about
      expect(response).to render_template :about
    end
  end
end
