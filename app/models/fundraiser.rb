class Fundraiser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :creator, :class_name => 'User'

  validates :title, :organization, :creator, :pledge_start_time, :pledge_end_time, :presence => true
  validate :pledge_start_time_before_pledge_end_time

  has_many :events, -> { order "start_time ASC" } do
    def past
      where("end_time <= ?", DateTime.now)
    end
    def present
      where("end_time > ? AND start_time <= ?", DateTime.now, DateTime.now)
    end
    def future
      where("start_time > ?", DateTime.now)
    end
  end

  has_many :teams, :through => :events
  has_many :pledges, :through => :events


  def has_started?
    self.pledge_start_time < DateTime.now
  end

  def has_ended?
    self.pledge_end_time < DateTime.now
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

  def pledge_start_time_before_pledge_end_time
    if pledge_start_time && pledge_end_time && pledge_start_time > pledge_end_time
      errors.add(:pledge_start_time, "can't be after the end time")
    end
  end

end
