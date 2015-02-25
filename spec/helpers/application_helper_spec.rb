require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  describe "secure_protocol" do
    describe "when in production" do
      before :each do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        expect(Rails.env.production?).to eq true
      end

      it "should be https" do
        expect(helper.secure_protocol()).to eq "https"
      end
    end

    describe "when in development" do
      before :each do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        expect(Rails.env.development?).to eq true
      end

      it "should be http" do
        expect(helper.secure_protocol()).to eq "http"
      end
    end

    describe "when in test" do
      before :each do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
        expect(Rails.env.test?).to eq true
      end

      it "should be http" do
        expect(helper.secure_protocol()).to eq "http"
      end
    end
  end
end
