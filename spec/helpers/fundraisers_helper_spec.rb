require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the FundraisersHelper. For example:
#
# describe FundraisersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe FundraisersHelper, :type => :helper do
  describe "thirty_minute_internvals" do
    it "creates array with every hour and half hour" do
      expected_times = []

      date = DateTime.parse('2000-01-01 00:00:00')
      max_date = DateTime.parse('2000-01-02 00:00:00')
      while (date < max_date)
        expected_times << date.strftime("%l:%M %P").strip
        date += 30.minutes
      end
      expect(helper.thirty_minute_internvals).to eq expected_times
    end
  end
end
