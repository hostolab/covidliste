class Match < ApplicationRecord
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
    return if confirmed?

    update(
      confirmed_at: Time.now.utc,
      age: user.age,
      zipcode: user.zipcode,
      city: user.city,
      geo_citycode: user.geo_citycode,
      geo_context: user.geo_context
    )
  end

  def confirmable?
    !confirmed? && campaign_batch.matches.confirmed.none?
  end

  def expired?
    !confirmed? && Time.now.utc > expires_at
  end
end
