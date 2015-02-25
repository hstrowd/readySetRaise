class Event < ActiveRecord::Base
  belongs_to :fundraiser
  has_one :organization, :through => :fundraiser
  belongs_to :creator, :class_name => 'User'
  belongs_to :team_descriptor

  validates :title, :fundraiser, :creator, :start_time, :end_time, :team_descriptor, :presence => true
  validates :title, length: { maximum: 255 }
  # Capping the description at 5000 characters to prevent malicious entries.
  validates :description, length: { maximum: 5000 }
  validate :start_time_before_end_time
  validate :start_time_after_fundraiser_start
  validate :end_time_before_fundraiser_end

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
    if start_time && end_time && (start_time > end_time)
      errors.add(:start_time, "can't be after the end time")
    end
  end

  def start_time_after_fundraiser_start
    if fundraiser && start_time && (start_time < fundraiser.pledge_start_time)
      errors.add(:start_time, "can't be before the fundraiser's started")
    end
  end

  def end_time_before_fundraiser_end
    if fundraiser && end_time && (end_time > fundraiser.pledge_end_time)
      errors.add(:end_time, "can't be after the fundraiser's ended")
    end
  end
end
