class Event < ActiveRecord::Base
  belongs_to :fundraiser
  has_one :organization, :through => :fundraiser
  belongs_to :creator, :class_name => 'User'

  validates :title, :start_time, :end_time, :presence => true

  has_many :teams
  has_many :pledges, :through => :teams

  def has_started?
    self.start_time < DateTime.now
  end

  def has_ended?
    self.end_time < DateTime.now
  end

  def is_active?
    has_started? && !has_ended?
  end


  def pledge_target
    self.teams.sum(:pledge_target)
  end

  def pledge_total
    self.pledges.sum(:amount)
  end

end
