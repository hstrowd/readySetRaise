class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :organization_memberships, foreign_key: "member_id"
  has_many :organizations, through: :organization_memberships

  validates :first_name, :last_name, presence: true

  def full_name
    first_name + ' ' + last_name
  end
end
