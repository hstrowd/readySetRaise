class Event < ActiveRecord::Base
  belongs_to :fundraiser
  has_one :organization, :through => :fundraiser
  belongs_to :creator, :class_name => 'User'

  validates :title, :fundraiser, :creator, :start_time, :end_time, :presence => true
  validate :start_time_before_end_time

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

private

  def start_time_before_end_time
    if start_time && end_time && start_time > end_time
      errors.add(:start_time, "can't be after the end time")
    end
  end

end
