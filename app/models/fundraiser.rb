class Fundraiser < ActiveRecord::Base
  belongs_to :organization

  validates :title, :pledge_start_time, :pledge_end_time, :presence => true
end
