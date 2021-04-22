class Match < ApplicationRecord
  class DoseOverbookingError < StandardError; end

  class AlreadyConfirmedError < StandardError; end

  class MissingNamesError < StandardError; end

  NO_MORE_THAN_ONE_MATCH_PER_PERIOD = 24.hours

  has_secure_token :match_confirmation_token

  belongs_to :vaccination_center
  belongs_to :campaign
  belongs_to :campaign_batch
  belongs_to :user

  accepts_nested_attributes_for :user

  encrypts :match_confirmation_token
  blind_index :match_confirmation_token

  validate :no_recent_match, on: :create
  before_create :save_user_info

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :refused, -> { where.not(refused_at: nil) }
  scope :pending, -> { where(confirmed_at: nil).where("expires_at >= now()") }

  def save_user_info
    self.age = user.age
    self.city = user.city
    self.zipcode = user.zipcode
    self.geo_citycode = user.geo_citycode
    self.geo_context = user.geo_context
    self
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def confirm!(source)
    raise MissingNamesError, "Vous devez renseigner votre identité" if user.missing_identity?

    raise AlreadyConfirmedError, "Vous avez déjà confirmé votre disponibilité" if confirmed?

    raise DoseOverbookingError, "La dose de vaccin a déjà été réservée" unless confirmable?

    self.confirmed_at = Time.now.utc
    self.source = source

    # temporary hack until all matches have the user data at creation
    self.age = user.age if age.nil?
    self.zipcode = user.zipcode if zipcode.nil?
    self.city = user.city if city.nil?
    self.geo_citycode = user.geo_citycode if geo_citycode.nil?
    self.geo_context = user.geo_context if geo_context.nil?

    save!
  end

  def confirmable?
    !confirmed? && campaign.remaining_slots > 0 && !refused?
  end

  def refuse!(source)
    update(refused_at: Time.now.utc, source: source)
  end

  def refused?
    !refused_at.nil?
  end

  def expired?
    !confirmed? && Time.now.utc > expires_at
  end

  def no_recent_match
    if user.matches.where("created_at >= ?", Match::NO_MORE_THAN_ONE_MATCH_PER_PERIOD.ago).any?
      errors.add(:base, "Cette personne a déjà été matchée récemment")
    end
  end
end
