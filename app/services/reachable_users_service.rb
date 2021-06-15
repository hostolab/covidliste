class ReachableUsersService
  def initialize(campaign)
    @campaign = campaign
    @vaccination_center = campaign.vaccination_center
    @ranking_method = campaign.ranking_method
    @covering = ::GridCoordsService.new(@vaccination_center.lat, @vaccination_center.lon).get_covering(@campaign.max_distance_in_meters)
  end

  def get_users(limit = nil)
    sql = <<~SQL.tr("\n", " ").squish
      select
      u.id as user_id,
      matches_count,
      ((SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) / 5.0)::int * 5 as distance_bucket
      from users u
      WHERE
        u.confirmed_at IS NOT NULL
        AND u.anonymized_at is NULL
        AND u.match_confirmed_at is NULL
        AND u.birthdate between (:min_date) and (:max_date)
        AND u.grid_i >= :min_i AND u.grid_i <= :max_i
        AND u.grid_j >= :min_j AND u.grid_j <= :max_j
        AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < (:rayon_km)
      ORDER by
        matches_count asc,
        distance_bucket asc,
        created_at desc
      LIMIT (:limit)
    SQL
    params = {
      min_date: @campaign&.max_age&.years&.ago,
      max_date: @campaign&.min_age&.years&.ago,
      lat: @vaccination_center.lat,
      lon: @vaccination_center.lon,
      rayon_km: @campaign.max_distance_in_meters / 1000,
      min_i: @covering[:center_cell][:i] - @covering[:dist_cells],
      max_i: @covering[:center_cell][:i] + @covering[:dist_cells],
      min_j: @covering[:center_cell][:j] - @covering[:dist_cells],
      max_j: @covering[:center_cell][:j] + @covering[:dist_cells],
      limit: limit
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    User.where(id: ActiveRecord::Base.connection.execute(query).to_a.pluck("user_id"))
  end

  def get_users_count
    sql = <<~SQL.tr("\n", " ").squish
      with reachable_users as
      (
        SELECT
          DISTINCT u.id
        FROM users u
        WHERE u.confirmed_at IS NOT NULL
        AND u.anonymized_at is NULL
        AND u.match_confirmed_at is NULL
        AND u.birthdate between (:min_date) and (:max_date)
        AND u.grid_i >= :min_i AND u.grid_i <= :max_i
        AND u.grid_j >= :min_j AND u.grid_j <= :max_j
        AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < (:rayon_km)
      ),
      matchable_users_count as (
        select count(distinct id) matchable_users_count
        from
        (
          select ru.id, sum(case when m.id is not null then 1 else 0 end) count
          from
            reachable_users ru
            left join matches m on (ru.id=m.user_id AND created_at >= :throttling_interval)
         group by ru.id
        ) a
        where count < :throttling_rate
      )

      select *
      from
        (select count(1) reachable_users_count from reachable_users) a
        join matchable_users_count on (1=1)
    SQL
    params = {
      min_date: @campaign&.max_age&.years&.ago,
      max_date: @campaign&.min_age&.years&.ago,
      lat: @vaccination_center.lat,
      lon: @vaccination_center.lon,
      rayon_km: @campaign.max_distance_in_meters / 1000,
      min_i: @covering[:center_cell][:i] - @covering[:dist_cells],
      max_i: @covering[:center_cell][:i] + @covering[:dist_cells],
      min_j: @covering[:center_cell][:j] - @covering[:dist_cells],
      max_j: @covering[:center_cell][:j] + @covering[:dist_cells],
      throttling_rate: @campaign.throttling_rate,
      throttling_interval: @campaign.throttling_interval.ago
    }

    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    ActiveRecord::Base.connection.execute(query).to_a.first
  end

  def self.get_running_campaigns_for_user(user)
    sql = <<~SQL.tr("\n", " ").squish
      WITH active_campaigns_for_user AS (
        SELECT
          c.id,
          c.available_doses,
          c.min_age,
          c.max_age,
          c.status,
          v.name,
          c.max_distance_in_meters/1000 as max_distance,
          (SQRT(((v.lat - (:lat))*110.574)^2 + ((v.lon - (:lon))*111.320*COS((:lat)::float*3.14159/180))^2)) as distance
        FROM
          campaigns c
          JOIN vaccination_centers v on (v.id = c.vaccination_center_id)
        WHERE
          c.status = 0
          AND c.ends_at > NOW()
          AND c.vaccine_type NOT IN ('astrazeneca', 'janssen')
          AND (:birthdate) between (NOW() - (c.max_age || ' years')::interval) and (NOW() - (c.min_age || ' years')::interval)
          AND (SQRT(((v.lat - (:lat))*110.574)^2 + ((v.lon - (:lon))*111.320*COS((:lat)::float*3.14159/180))^2)) < c.max_distance_in_meters/1000
      )

      SELECT
        c.id as campaign_id,
        c.available_doses,
        COALESCE(cm.n_confirmed_matches, 0) as n_confirmed_matches,
        COALESCE(um.n_user_matches, 0) as n_user_matches,
        c.min_age,
        c.max_age,
        c.status,
        c.name,
        c.max_distance,
        c.distance
      FROM
        active_campaigns_for_user c
      LEFT JOIN (
        SELECT campaign_id, COUNT(*) AS n_confirmed_matches
        FROM
          matches m
        JOIN active_campaigns_for_user ac ON (ac.id=m.campaign_id)
        WHERE m.user_id = (:id)
        AND confirmed_at IS NOT NULL
        GROUP BY 1
      ) cm ON c.id = cm.campaign_id
      LEFT JOIN (
        SELECT campaign_id, COUNT(*) AS n_user_matches
        FROM
          matches m
        JOIN active_campaigns_for_user ac ON (ac.id=m.campaign_id)
        WHERE m.user_id = (:id)
        GROUP BY 1
      ) um ON c.id = um.campaign_id
      WHERE
        COALESCE(um.n_user_matches, 0) = 0
      ORDER BY c.id ASC
    SQL
    params = {
      id: user.id,
      birthdate: user.birthdate,
      lat: user.lat,
      lon: user.lon
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    Campaign.where(id: ActiveRecord::Base.connection.execute(query).to_a.pluck("campaign_id")).includes([:vaccination_center])
  end
end
