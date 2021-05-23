class Partner < ApplicationRecord
  include HasPhoneNumberConcern
  has_phone_number_types %i[mobile]

  devise :database_authenticatable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :zxcvbnable,
    :lockable,
    :omniauthable, omniauth_providers: [:pro_sante_connect, :bimedoc]

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :email, 'valid_email_2/email': {mx: true, message: "Email invalide"}
  validates :statement, presence: true, acceptance: true, unless: :reset_password_token?

  encrypts :email
  encrypts :phone_number
  encrypts :name
  blind_index :email

  has_many :partner_vaccination_centers
  has_many :partner_external_accounts
  has_many :vaccination_centers, -> { where.not(confirmed_at: nil) }, through: :partner_vaccination_centers
  has_many :unconfirmed_vaccination_centers, lambda {
                                               where(confirmed_at: nil)
                                             }, through: :partner_vaccination_centers, source: :vaccination_center
  has_many :messages, class_name: "Ahoy::Message", as: :partner

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def full_name
    name
  end

  def to_s
    full_name
  end

  def skip_password_complexity?
    !encrypted_password_changed?
  end

  def to_csv
    columns = %w[created_at updated_at email name phone_number]
    CSV.generate(headers: true) do |csv|
      csv << columns
      csv << columns.map { |column| public_send(column) }
    end
  end
end
