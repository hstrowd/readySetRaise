class Event < ActiveRecord::Base
  belongs_to :fundraiser
  has_one :organization, :through => :fundraiser
  belongs_to :creator, :class_name => 'User'

  validates :title, :start_time, :end_time, :presence => true

  has_many :teams

end
