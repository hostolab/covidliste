class ReachableUsersService 

  def initialize(campaign)
    @campaign = campaign
    @vaccination_center = campaign.vaccination_center
    @ranking_method = campaign.ranking_method
  end

  def get_users(limit = nil)
    return get_users_with_v2(limit) if @ranking_method == "v2"
    get_users_with_random(limit)
  end

  def get_users_with_v2(limit = nil)
    sql = <<~SQL.tr("\n", ' ').squish
      with reachable_users as (
        SELECT
        u.id as user_id,
        (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2))  as distance
        FROM users u
        WHERE u.confirmed_at IS NOT NULL 
        AND u.anonymized_at is NULL
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
      min_date: @campaign.max_age.years.ago, 
      max_date: @campaign.min_age.years.ago,
      lat: @vaccination_center.lat,
      lon: @vaccination_center.lon,
      rayon_km: @campaign.max_distance_in_meters / 1000,
      vaccine_type: @campaign.vaccine_type,
      limit: limit
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    User.where(ActiveRecord::Base.connection.execute(query).to_a.pluck(:user_id))
  end


  def get_users_with_random(limit = nil)
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

end
