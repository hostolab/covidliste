class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :birthdate, presence: true
  validates :toc, presence: true, acceptance: true

  scope :confirmed, -> { where.not(confirmed_at: nil) }


  def full_name
    "#{firstname} #{lastname}"
  end

  def confirmed?
    confirmed_at.present?
  end

  protected

  # Devise override
  def password_required?
    confirmed? ? super : false
  end

end
