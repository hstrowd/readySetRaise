class Pledge < ActiveRecord::Base
  belongs_to :team
  belongs_to :donor, :class_name => 'User'
  has_one :event, :through => :team
  has_one :fundraiser, :through => :team
  has_one :organization, :through => :team

  validates :amount, :team, :donor, :presence => true
  validates :anonymous, :monthly, :inclusion => {:in => [true, false]}
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
