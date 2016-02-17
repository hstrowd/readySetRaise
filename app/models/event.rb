class Event < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User'
  belongs_to :team_descriptor

  has_many :teams
  has_many :pledges, :through => :teams do
    def one_time
      where("monthly = FALSE")
    end
    def monthly
      where("monthly = TRUE")
    end
  end

  validates :title, :creator, :start_time, :end_time, :team_descriptor, :presence => true
  validates :title, length: { maximum: 255 }
  validates :url_key, {
    format: { with: /\A[a-zA-Z\-_.~0-9]+\z/, message: "must be URL safe (i.e. alphanumeric or '-', '_', '.', or '~')" },
    # This could alternatively be done using ActionController::Routing::Routes.recognize_path
    exclusion: { in: ApplicationController.reserved_routing_keywords },
    allow_blank: true,
    uniqueness: true,
    length: { maximum: 255 }
  }
  # Capping the description at 5000 characters to prevent malicious entries.
  validates :description, length: { maximum: 5000 }
  validate :start_time_before_end_time

  validates_with UrlValidator, fields: [:logo_url]

  def has_started?
    self.start_time < DateTime.now
  end

  def has_ended?
    self.end_time < DateTime.now
  end

  def is_active?
    has_started? && !has_ended?
  end

  def is_member?(user)
    user.is_admin?
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
end
