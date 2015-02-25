class TeamDescriptor < ActiveRecord::Base
  has_many :events

  validates :singular, :plural, :presence => true, length: { maximum: 255 }
end
