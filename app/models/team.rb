class Team < ActiveRecord::Base
  belongs_to :event
  has_one :fundraiser, :through => :event
  has_one :organization, :through => :event

  validates :name, :presence => true
  validates_numericality_of :pledge_target
end
