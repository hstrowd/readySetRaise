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

  has_many :fundraisers

  # TODO: Add fields for primary color, secondary color, logo, key
end
