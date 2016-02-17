class Pledge < ActiveRecord::Base
  belongs_to :team
  belongs_to :donor, :class_name => 'User'
  has_one :event, :through => :team

  validates :amount, :team, :donor, :presence => true
  validates :anonymous, :monthly, :inclusion => {:in => [true, false]}
  validates :amount, numericality: { greater_than: 0 }
  validates :comment, length: { maximum: 255 }
end
