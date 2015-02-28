class Organization < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User'
  has_many :memberships, :class_name => 'OrganizationMembership'
  has_many :members, :through => :memberships

  has_many :fundraisers, -> { order "pledge_start_time ASC" } do
    def past
      where("pledge_end_time <= ?", DateTime.now)
    end
    def present
      where("pledge_end_time > ? AND pledge_start_time <= ?", DateTime.now, DateTime.now)
    end
    def future
      where("pledge_start_time > ?", DateTime.now)
    end
  end
  has_many :events, :through => :fundraisers

  validates :name, :description, :homepage_url, :donation_url, :creator, :presence => true
  validates :url_key, {
    format: { with: /\A[a-zA-Z\-_.~0-9]+\z/, message: "must be URL safe (i.e. alphanumeric or '-', '_', '.', or '~')" },
    exclusion: { in: ApplicationController.reserved_routing_keywords },
    presence: true,
    uniqueness: true,
    length: { maximum: 255 }
  }

  validates :name, :homepage_url, :donation_url, :logo_url, length: { maximum: 255 }
  # Capping the description at 5000 characters to prevent malicious entries.
  validates :description, length: { maximum: 5000 }

  validates_with UrlValidator, fields: [:homepage_url, :donation_url, :logo_url]
end
