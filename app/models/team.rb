class Team < ActiveRecord::Base
  belongs_to :event
  has_one :fundraiser, :through => :event
  has_one :organization, :through => :event
  has_many :pledges

  validates :name, :event, :presence => true
  validates_numericality_of :pledge_target

  def pledge_total
    self.pledges.sum(:amount)
  end
end
