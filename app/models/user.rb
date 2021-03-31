class User < ApplicationRecord

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true, uniqueness: true
  validates :address, presence: true
  validates :birthdate, presence: true
  validates :toc, presence: true, acceptance: true

  after_create :send_welcome_email


  def full_name
    "#{firstname} #{lastname}"
  end

  def send_welcome_email
    Mailer.welcome_user(id).deliver_later
  end

end
