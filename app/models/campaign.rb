class Campaign < ApplicationRecord
  MAX_DOSES = 200
  MAX_DISTANCE_IN_KM = 50
  MAX_SMS_BUDGET_BY_DOSE = 20
  OVERBOOKING_FACTOR = 40

  belongs_to :vaccination_center
  belongs_to :partner

  has_many :matches

  enum status: {running: 0, completed: 1, canceled: 2}

  validates :available_doses, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_DOSES}
  validates :vaccine_type, presence: true
  validates :min_age, numericality: {greater_than: 17}
  validates :max_age, numericality: {greater_than: 17}
  validates :max_distance_in_meters, numericality: {greater_than: 0, less_than_or_equal_to: MAX_DISTANCE_IN_KM * 1000}
  validate :min_age_lesser_than_max_age
  validate :starts_at_lesser_than_ends_at

  before_create :set_parameters
  after_create_commit :notify_to_slack

  def canceled!
    update_attribute(:canceled_at, Time.now.utc)
    update_attribute(:available_doses, matches.confirmed.count)
    super
  end

  def remaining_doses
    [available_doses - matches.confirmed.count, 0].max
  end

  def target_matches_count
    # number of people to target at any point in time
    remaining_doses * OVERBOOKING_FACTOR
  end

  def sms_budget_remaining
    (available_doses * MAX_SMS_BUDGET_BY_DOSE) - matches.with_sms.count
  end

  def reachable_users_query(limit: nil)
    ::ReachableUsersService.new(self).get_users(limit)
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

  def set_parameters
    self.parameters =
      {
        algo_version: Flipper.enabled?(:matching_algo_v3) ? "v3" : "v2",
        ranking_method: Flipper.enabled?(:ranking_method_v2) ? "v2" : "v1",
        overbooking_factor: OVERBOOKING_FACTOR,
        max_sms_budget_by_dose: MAX_SMS_BUDGET_BY_DOSE
      }
  end

  def algo_version
    ((parameters || {})[:algo_version]) || "v2"
  end

  def ranking_method
    ((parameters || {})[:ranking_method]) || "v1"
  end

  def matching_algo_v2?
    algo_version == "v2"
  end

  def matching_algo_v3?
    algo_version == "v3"
  end

  def notify_to_slack
    PushNewCampaignToSlackJob.perform_later(id)
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
