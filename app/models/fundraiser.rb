class Fundraiser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :creator, :class_name => 'User'

  validates :title, :pledge_start_time, :pledge_end_time, :presence => true

  has_many :events do
    def past
      where("end_time <= ?", DateTime.now)
    end
    def present
      where("end_time > ? AND start_time <= ?", DateTime.now, DateTime.now)
    end
    def future
      where("start_time > ?", DateTime.now)
    end
  end
end
