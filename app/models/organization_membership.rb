class OrganizationMembership < ActiveRecord::Base

  belongs_to :organization
  belongs_to :member, :class_name => 'User'

  validates :organization, :member, :presence => true

end
