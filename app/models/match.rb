class Match < ApplicationRecord
  class DoseOverbookingError < StandardError; end

  class AlreadyConfirmedError < StandardError; end

  class MissingNamesError < StandardError; end

  THROTTLING_RATE = 5
  THROTTLING_INTERVAL = 24.hours

  MATCH_TTL = 45.minutes

  has_secure_token :match_confirmation_token

  belongs_to :vaccination_center
  belongs_to :campaign
  belongs_to :user

  accepts_nested_attributes_for :user

  encrypts :match_confirmation_token
  blind_index :match_confirmation_token

  enum sms_provider: {twilio: "twilio", sendinblue: "sendinblue"}, _prefix: :sms_provider
  enum sms_status: {pending: "pending", success: "success", error: "error"}, _default: :pending, _prefix: :sms_status

  validates :distance_in_meters, numericality: {greater_than_or_equal_to: 0, only_integer: true}, allow_nil: true
  validate :match_throttling, on: :create
  validates :user_id, uniqueness: {scope: :campaign_id}
  before_create :save_user_info
  before_save :cache_distance_in_meters_between_user_and_vaccination_center
  after_create_commit :notify

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :refused, -> { where.not(refused_at: nil) }
  scope :pending, -> { where(confirmed_at: nil, refused_at: nil).where("expires_at >= now()") }
  scope :email_only, -> { where(sms_sent_at: nil).where.not(mail_sent_at: nil) }
  scope :with_sms, -> { where.not(sms_sent_at: nil) }
  scope :no_email_click, -> { where(email_first_clicked_at: nil) }
  scope :alive, -> { where("created_at >= ?", MATCH_TTL.ago) }

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

  def find_other_available_match_for_user
    sql = <<~SQL.tr("\n", " ").squish
      WITH user_campaigns AS (
        SELECT DISTINCT c.id, c.available_doses
        FROM
          campaigns c
          JOIN matches m ON (m.campaign_id=c.id)
        WHERE
          m.user_id = :user_id
      ), remaining_doses_campaigns AS (
        SELECT id
        FROM (
          SELECT uc.id, GREATEST(0, uc.available_doses - SUM(CASE WHEN confirmed_at IS NOT NULL THEN 1 ELSE 0 END)) remaining_doses
          FROM
            matches m
            JOIN user_campaigns uc ON (m.campaign_id=uc.id)
          GROUP BY uc.id, uc.available_doses
        ) a
        WHERE remaining_doses > 0
      )

      SELECT
        m.id
      FROM
        matches m
        JOIN remaining_doses_campaigns c ON (m.campaign_id=c.id)
      WHERE
        m.id != :match_id
        AND m.user_id = :user_id
        AND confirmed_at IS NULL
        AND refused_at IS NULL
        AND expires_at >= now()
      ORDER BY id
      LIMIT 1
    SQL
    params = {
      user_id: self.user_id,
      match_id: self.id
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    Match.where(id: ActiveRecord::Base.connection.execute(query).to_a.pluck("id")).first
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
    self.expires_at = campaign.ends_at
    save
  end

  def match_throttling
    return unless user
    matches_count = user.matches.where("created_at >= ?", THROTTLING_INTERVAL.ago).count
    errors.add(:base, "Too many matches for this user") if matches_count >= THROTTLING_RATE
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

  def sorting_string
    "#{user&.lastname&.strip || "Anonymous"} #{user&.firstname&.strip || "Anonymous"} #{user&.birthdate&.strftime("%d/%m/%Y")} #{confirmed_at}".titleize
  end

  def notify
    notify_by_email
  end

  def notify_by_email
    SendMatchEmailJob.perform_later(id)
  end

  def notify_by_sms
    SendMatchSmsJob.perform_later(id)
  end

  def flipper_id
    "#{self.class.name}_#{id}"
  end

  def sms_notification_needed?
    can_receive_sms? && sms_sent_at.blank? && !expired? && !sms_status_error?
  end

  def can_receive_sms?
    user.present? && user.phone_number.present?
  end
end
