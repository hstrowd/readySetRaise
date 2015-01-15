class Team < ActiveRecord::Base
  belongs_to :event

  validates :name, :presence => true
  validates_numericality_of :pledge_target
end
