class Campaign < ApplicationRecord
  MAX_DOSES = 200
  MAX_DISTANCE_IN_KM = 50
  MAX_SMS_BUDGET_BY_DOSE = 50

  belongs_to :vaccination_center
  belongs_to :partner

  has_many :matches

  enum status: {running: 0, completed: 1, canceled: 2}

  validates :available_doses, numericality: {greater_than: 0, less_than_or_equal_to: MAX_DOSES}
  validates :vaccine_type, presence: true
  validates :min_age, numericality: {greater_than: 17}
  validates :max_age, numericality: {greater_than: 17}
  validates :max_distance_in_meters, numericality: {greater_than: 0, less_than_or_equal_to: MAX_DISTANCE_IN_KM * 1000}
  validate :min_age_lesser_than_max_age
  validate :starts_at_lesser_than_ends_at

  def canceled!
    update_attribute(:canceled_at, Time.now.utc)
    super
  end

  def remaining_doses
    [available_doses - matches.confirmed.count, 0].max
  end

  def target_matches_count
    # number of people to target at any point in time
    remaining_doses * Vaccine.overbooking_factor(vaccine_type)
  end

  def sms_budget_remaining
    (available_doses * MAX_SMS_BUDGET_BY_DOSE) - matches.with_sms.count
  end

  def reachable_users_query(limit: nil)
    User.confirmed.active
      .where("EXTRACT(YEAR FROM AGE(birthdate))::int BETWEEN ? AND ?", min_age, max_age)
      .where("SQRT(((? - lat)*110.574)^2 + ((? - lon)*111.320*COS(lat::float*3.14159/180))^2) < ?", vaccination_center.lat, vaccination_center.lon, max_distance_in_meters / 1000)
      .where("id not in (
        select user_id from matches
        where user_id is not null
        and ((created_at >= now() - interval '24 hours') or (confirmed_at is not null))
        )") # exclude user_id that have been matched in the last 24 hours, or confirmed
      .order("RANDOM()")
      .limit(limit)
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[firstname lastname birthdate phone_number confirmed_at]
      matches.confirmed.order(:confirmed_at).each do |match|
        next if match.user.nil?

        csv << [
          match.user.firstname || "Anonymous",
          match.user.lastname,
          match.user.birthdate,
          match.user.human_friendly_phone_number,
          match.confirmed_at
        ]
      end
    end
  end

  private

  def min_age_lesser_than_max_age
    if (min_age || 0) >= (max_age || 0)
      errors.add(:max_age, "doit être supérieur à l’âge minimum")
    end
  end

  def starts_at_lesser_than_ends_at
    if starts_at >= ends_at
      errors.add(:ends_at, "doit être postérieur à la date de début")
    end
  end
end
