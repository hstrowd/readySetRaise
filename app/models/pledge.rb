class Pledge < ActiveRecord::Base
  belongs_to :team
  belongs_to :donor, :class_name => 'User'
  has_one :event, :through => :team
  has_one :fundraiser, :through => :team
  has_one :organization, :through => :team

  validates :amount, :team, :donor, :presence => true
  validates_numericality_of :amount

  # TODO: Add annonymous flag.
end
