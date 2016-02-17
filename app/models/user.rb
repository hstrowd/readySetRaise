class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Don't require passwords.
  def password_required?
    false
  end

  validates :first_name, :last_name, presence: true
  validates :email, :first_name, :last_name, :phone_number, length: { maximum: 255 }

  ADMIN_EMAIL_ADDRESSES = %w(hstrowd@gmail.com)

  def full_name
    first_name + ' ' + last_name
  end

  def is_admin?
    ADMIN_EMAIL_ADDRESSES.include?(email)
  end
end
