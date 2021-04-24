class Campaign < ApplicationRecord
  MAX_DOSES = 200
  MAX_DISTANCE_IN_KM = 50
  AVG_SMS_COUNT_COST_PER_DOSE = 100

  belongs_to :vaccination_center
  belongs_to :partner

  has_many :campaign_batches
  has_many :matches

  enum status: {running: 0, completed: 1, canceled: 2}

  validates :available_doses, numericality: {greater_than: 0, less_than_or_equal_to: MAX_DOSES}
  validates :sms_sent_count, :sms_max_count, numericality: {greater_than_or_equal_to: 0}
  validates :vaccine_type, presence: true
  validates :min_age, numericality: {greater_than: 17}
  validates :max_age, numericality: {greater_than: 17}
  validates :max_distance_in_meters, numericality: {greater_than: 0, less_than_or_equal_to: MAX_DISTANCE_IN_KM * 1000}
  validate :min_age_lesser_than_max_age
  validate :starts_at_lesser_than_ends_at
  validate :sms_sent_count_lesser_or_equal_than_sms_max_count

  before_validation :compute_derived_calculations

  def canceled!
    update_attribute(:canceled_at, Time.now.utc)
    super
  end

  def remaining_slots
    available_doses - matches.confirmed.size
  end

  def sms_exhausted?
    sms_sent_count >= sms_max_count
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

  def sms_sent_count_lesser_or_equal_than_sms_max_count
    if sms_sent_count > sms_max_count
      errors.add(:base, "a atteint son doit être postérieur à la date de début")
    end
  end

  def compute_sms_max_count
    return if sms_max_count.to_i > 0
    self.sms_max_count = (available_doses * Vaccine.average_sms_count_cost_per_dose(vaccine_type)).floor if available_doses
  end

  def compute_derived_calculations
    compute_sms_max_count
  end
end
