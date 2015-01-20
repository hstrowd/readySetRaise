class Pledge < ActiveRecord::Base
  belongs_to :team
  has_one :event, :through => :team
  has_one :fundraiser, :through => :team
  has_one :organization, :through => :team

  validates :amount, :presence => true
  validates_numericality_of :amount
end
