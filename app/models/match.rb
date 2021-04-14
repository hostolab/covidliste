class Match < ApplicationRecord
  class DoseOverbookingError < StandardError; end

  class AlreadyConfirmedError < StandardError; end

  has_secure_token :match_confirmation_token

  belongs_to :vaccination_center
  belongs_to :campaign
  belongs_to :campaign_batch
  belongs_to :user

  encrypts :match_confirmation_token
  blind_index :match_confirmation_token

  before_create :save_user_info

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def save_user_info
    self.age = user.age
    self.city = user.city
    self.zipcode = user.zipcode
    self.geo_citycode = user.geo_citycode
    self.geo_context = user.geo_context
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def confirm!
    raise AlreadyConfirmedError, "Vous avez déjà confirmé votre disponibilité" if confirmed?

    raise DoseOverbookingError, "La dose de vaccin a déjà été réservée" unless confirmable?

    update(confirmed_at: Time.now.utc)

    # temporary hack until all matches have the user data at creation
    if age.nil? || zipcode.nil? || city.nil?
      update(age: user.age,
             zipcode: user.zipcode,
             city: user.city,
             geo_citycode: user.geo_citycode,
             geo_context: user.geo_context)
    end
  end

  def confirmable?
    !confirmed? && campaign.remaining_slots > 0
  end

  def expired?
    !confirmed? && Time.now.utc > expires_at
  end
end
