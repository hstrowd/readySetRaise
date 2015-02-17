class Team < ActiveRecord::Base
  belongs_to :event
  has_one :fundraiser, :through => :event
  has_one :organization, :through => :event
  has_many :pledges

  validates :name, :event, :pledge_target, :presence => true
  validates :name, length: { maximum: 255 }
  validates_numericality_of :pledge_target, unless: "pledge_target.nil?"

  def pledge_total
    self.pledges.sum(:amount)
  end
end
