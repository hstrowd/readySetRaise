class Team < ActiveRecord::Base
  belongs_to :event
  has_many :pledges do
    def one_time
      where("monthly = FALSE")
    end
    def monthly
      where("monthly = TRUE")
    end
  end

  validates :name, :event, :pledge_target, :presence => true
  validates :name, length: { maximum: 255 }
  validates_numericality_of :pledge_target, unless: "pledge_target.nil?"

  def pledge_total
    self.pledges.one_time.sum(:amount) +
      (self.pledges.monthly.sum(:amount) * 12)
  end
end
