class Event < ActiveRecord::Base
  belongs_to :fundraiser
  has_one :organization, :through => :fundraiser
  belongs_to :creator, :class_name => 'User'
  belongs_to :team_descriptor

  validates :title, :fundraiser, :creator, :start_time, :end_time, :team_descriptor, :presence => true
  validates :title, length: { maximum: 255 }
  validates :url_key, {
    format: { with: /\A[a-zA-Z\-_.~0-9]+\z/, message: "must be URL safe (i.e. alphanumeric or '-', '_', '.', or '~')" },
    allow_blank: true,
    length: { maximum: 255 }
  }
  # Capping the description at 5000 characters to prevent malicious entries.
  validates :description, length: { maximum: 5000 }
  validate :start_time_before_end_time
  validate :start_time_after_fundraiser_start
  validate :end_time_before_fundraiser_end
  validate :url_key_unique_to_company

  has_many :teams
  has_many :pledges, :through => :teams do
    def one_time
      where("monthly = FALSE")
    end
    def monthly
      where("monthly = TRUE")
    end
  end


  def self.find_by_org_and_event_url_keys(org_url_key, event_url_key)
    org = Organization.find_by_url_key(org_url_key)
    return nil if !org

    events = Event.joins(:organization).where("events.url_key = ? AND organization_id = \?", event_url_key, org.id);
    return nil if events.blank?

    if events.size > 1
      logger.error("Multiple events found with URL key '#{event_url_key}' in organization #{org.id}")
    end

    return events.first
  end


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
    self.pledges.one_time.sum(:amount) +
      (self.pledges.monthly.sum(:amount) * 12)
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

  def url_key_unique_to_company
    if organization && url_key
      if !id.blank? && !organization.events.where("url_key = ? AND events.id != ?", url_key, id).empty?
        errors.add(:url_key, "has already been taken")
      elsif id.blank? && !organization.events.where("url_key = ?", url_key).empty?
        errors.add(:url_key, "has already been taken")
      end
    end
  end
end
