class Fundraiser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :creator, :class_name => 'User'

  validates :title, :pledge_start_time, :pledge_end_time, :presence => true

  has_many :events do
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

end
