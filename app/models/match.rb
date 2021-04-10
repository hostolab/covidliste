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

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    !confirmed_at.nil?
  end

  def confirm!
    raise AlreadyConfirmedError, "Vous avez déjà confirmé votre disponibilité" if confirmed?

    raise DoseOverbookingError, "La dose de vaccin a déjà été réservée" unless confirmable?

    update(
      confirmed_at: Time.now.utc,
      age: user.age,
      zipcode: user.zipcode,
      city: user.city,
      geo_citycode: user.geo_citycode,
      geo_context: user.geo_context
    )

    update(confirmed_at: Time.now.utc)
  end

  def confirmable?
    !confirmed? && campaign.remaining_slots > 0
  end

  def expired?
    !confirmed? && Time.now.utc > expires_at
  end
end
