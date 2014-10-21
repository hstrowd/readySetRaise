class Fundraiser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :creator, :class_name => 'User'

  validates :title, :pledge_start_time, :pledge_end_time, :presence => true
end
