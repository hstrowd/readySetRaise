class Organization < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User'
  has_many :memberships, :class_name => 'OrganizationMembership'
  has_many :members, :through => :memberships

  validates :name, :description, :homepage_url, :creator, :presence => true
  validates :url_key, {
    format: { with: /\A[a-zA-Z\-_.~0-9]+\z/, message: "must be URL safe" },
    presence: true,
    uniqueness: true
  }

  has_many :fundraisers do
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

  # TODO: Add fields for primary color, secondary color, logo, key
end
