class Match < ApplicationRecord
  class DoseOverbookingError < StandardError; end

  class AlreadyConfirmedError < StandardError; end

  class MissingNamesError < StandardError; end

  NO_MORE_THAN_ONE_MATCH_PER_PERIOD = 24.hours
  EXPIRE_IN_MINUTES = 30
  DEAD_AFTER = 2.hours

  has_secure_token :match_confirmation_token

  belongs_to :vaccination_center
  belongs_to :campaign
  belongs_to :user

  accepts_nested_attributes_for :user

  encrypts :match_confirmation_token
  blind_index :match_confirmation_token

  validates :distance_in_meters, numericality: {greater_than_or_equal_to: 0, only_integer: true}, allow_nil: true
  validate :no_recent_match, on: :create
  before_create :save_user_info
  before_save :cache_distance_in_meters_between_user_and_vaccination_center
  after_create_commit :notify

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :refused, -> { where.not(refused_at: nil) }
  scope :pending, -> { where(confirmed_at: nil, refused_at: nil).where("expires_at >= now()") }
  scope :email_only, -> { where(sms_sent_at: nil).where.not(mail_sent_at: nil) }
  scope :with_sms, -> { where.not(sms_sent_at: nil) }
  scope :no_email_click, -> { where(email_first_clicked_at: nil) }
  scope :alive, -> { where("created_at >= ?", DEAD_AFTER.ago) }

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

  def confirm!
    raise MissingNamesError, "Vous devez renseigner votre identité" if user.missing_identity?

    raise AlreadyConfirmedError, "Vous avez déjà confirmé votre disponibilité" if confirmed?

    raise DoseOverbookingError, "La dose de vaccin a déjà été réservée" unless confirmable?

    self.confirmed_at = Time.now.utc

    # temporary hack until all matches have the user data at creation
    self.age = user.age if age.nil?
    self.zipcode = user.zipcode if zipcode.nil?
    self.city = user.city if city.nil?
    self.geo_citycode = user.geo_citycode if geo_citycode.nil?
    self.geo_context = user.geo_context if geo_context.nil?

    save!
  end

  def confirmable?
    !confirmed? && campaign.remaining_doses > 0 && !refused?
  end

  def refuse!
    update(refused_at: Time.now.utc)
  end

  def refused?
    !refused_at.nil?
  end

  def expired?
    !confirmed? && expires_at && Time.now.utc > expires_at
  end

  def set_expiration!
    return unless expires_at.nil?
    self.expires_at = if matching_algo_v2?
      campaign.ends_at
    else
      [Time.now.utc + Match::EXPIRE_IN_MINUTES.minutes, campaign.ends_at].min
    end
    save
  end

  def no_recent_match
    if user.present? && user.matches.where("created_at >= ?", Match::NO_MORE_THAN_ONE_MATCH_PER_PERIOD.ago).any?
      errors.add(:base, "Cette personne a déjà été matchée récemment")
    end
  end

  def cache_distance_in_meters_between_user_and_vaccination_center
    if distance_in_meters.nil?
      if user.present? && user.lat.present? && user.lon.present?
        if vaccination_center.present? && vaccination_center.lat.present? && vaccination_center.lon.present?
          self.distance_in_meters = Geocoder::Calculations.distance_between(
            [user.lat, user.lon],
            [vaccination_center.lat, vaccination_center.lon],
            {unit: :m}
          )
        end
      end
    end
  end

  def notify
    notify_by_email
    notify_by_sms unless matching_algo_v2?
  end

  def notify_by_email
    SendMatchEmailJob.perform_later(self)
  end

  def notify_by_sms
    SendMatchSmsJob.perform_later(self)
  end

  def matching_algo_v2?
    campaign.matching_algo_v2?
  end
end
