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
    return reachable_users_query_v2(limit) if ranking_method == "v2"
    reachable_users_query_v1(limit)
  end

  def reachable_users_query_v2(limit: nil)
    sql = <<~SQL.tr("\n", ' ').squish
        with reachable_users as (
          SELECT
          u.id as user_id,
          (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2))  as distance
          FROM users u
          WHERE u.confirmed_at IS NOT NULL 
          AND u.birthdate between (:min_date) and (:max_date)
          AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < (:rayon_km)) 
        )
        ,users_stats as (
          select
          u.id as user_id,
          (distance / 5.0)::int * 5 as distance_bucket,
          u.created_at::date as created_at,
          COUNT(m.id) filter (where vaccine_type = (:vaccine_type)) as vaccine_matches_count,
          COUNT(m.id) as total_matches_count,
          MAX(m.created_at) filter (where vaccine_type = (:vaccine_type))  as last_vaccine_match,
          MAX(m.created_at)::date as last_match,
          SUM(case when m.refused_at is not null and vaccine_type = (:vaccine_type) then 1 else null end) as vaccine_refusals_count,
          SUM(case when m.refused_at is not null then 1 else null end) as total_refusals_count
          from reachable_users r
          inner join users u on (r.user_id = u.id)
          left outer join matches m on (m.user_id = r.user_id and m.status != 2)
          left outer join campaigns c on (c.id = m.campaign_id)
          group by 1,2,3
        )

        select 
          user_id,
          vaccine_matches_count,
          distance_bucket,
          total_matches_count,
          COALESCE(last_match, created_at) as last_match_or_signup,
          vaccine_refusals_count,
          total_refusals_count
          from users_stats 
          order by 
          vaccine_matches_count asc,
          distance_bucket asc,
          total_matches_count,
          COALESCE(last_match, created_at) asc,
          vaccine_refusals_count asc,
          total_refusals_count asc
        limit (:limit)
      SQL
    params = {
      min_date: max_age.years.ago, 
      max_date: min_age.years.ago,
      lat: vaccination_center.lat,
      lon: vaccination_center.lon,
      rayon_km:  max_distance_in_meters / 1000,
      vaccine_type: vaccine_type
      limit: limit
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    ActiveRecord::Base.connection.execute(query).to_a
  end


  def reachable_users_query_v1(limit: nil)
    User
    .confirmed
    .active
    .between_age(min_age, max_age)
    .where("SQRT(((? - lat)*110.574)^2 + ((? - lon)*111.320*COS(lat::float*3.14159/180))^2) < ?", vaccination_center.lat, vaccination_center.lon, max_distance_in_meters / 1000)
    .where("id not in (
      select user_id from matches m inner join campaigns c on (c.id = m.campaign_id)
      where m.user_id is not null
      and ((m.created_at >= now() - interval '24 hours' and c.status != 2) or (m.confirmed_at is not null))
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

  def set_parameters
    self.parameters = 
    {
      algo_version: Flipper.enabled?(:matching_algo_v3) ? "v3" : "v2",
      ranking_method: Flipper.enabled?(:ranking_method_v2) ? "v2" : "v1",
      overbooking_factor: OVERBOOKING_FACTOR,
      max_sms_budget_by_dose: MAX_SMS_BUDGET_BY_DOSE,
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
