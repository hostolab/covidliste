class ReachableUsersService
  def initialize(campaign)
    @campaign = campaign
    @vaccination_center = campaign.vaccination_center
    @ranking_method = campaign.ranking_method
    @covering = ::GridCoordsService.new(@vaccination_center.lat, @vaccination_center.lon).get_covering(@campaign.max_distance_in_meters)
  end

  def get_users(limit = nil)
    sql = <<~SQL.tr("\n", " ").squish
      with users_stats as (
        select
        u.id as user_id,
        ((SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) / 5.0)::int * 5 as distance_bucket,
        EXTRACT(EPOCH FROM (now() - u.created_at)) as created_at,
        COUNT(m.id) as total_matches_count
        from users u
        left outer join matches m on (m.user_id = u.id)
        left outer join campaigns c on (c.id = m.campaign_id and c.status != 2)
        WHERE
          u.confirmed_at IS NOT NULL
          AND u.anonymized_at is NULL
          AND u.birthdate between (:min_date) and (:max_date)
          AND u.grid_i >= :min_i AND u.grid_i <= :max_i
          AND u.grid_j >= :min_j AND u.grid_j <= :max_j
          AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < (:rayon_km)
        group by 1,2,3
        having SUM(case when m.confirmed_at is not null then 1 else 0 end) <= 0
      )

      select
        *
        from users_stats
        order by
        total_matches_count asc,
        distance_bucket asc,
        case when :ranking_method = 'v3' then - created_at else created_at end asc
      limit (:limit)
    SQL
    params = {
      min_date: @campaign.max_age.years.ago,
      max_date: @campaign.min_age.years.ago,
      lat: @vaccination_center.lat,
      lon: @vaccination_center.lon,
      rayon_km: @campaign.max_distance_in_meters / 1000,
      min_i: @covering[:center_cell][:i] - @covering[:dist_cells],
      max_i: @covering[:center_cell][:i] + @covering[:dist_cells],
      min_j: @covering[:center_cell][:j] - @covering[:dist_cells],
      max_j: @covering[:center_cell][:j] + @covering[:dist_cells],
      vaccine_type: @campaign.vaccine_type,
      limit: limit,
      ranking_method: @campaign.ranking_method
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
        left outer join matches m on (m.user_id = u.id and m.confirmed_at is not null)
        WHERE u.confirmed_at IS NOT NULL
        AND u.anonymized_at is NULL
        AND u.birthdate between (:min_date) and (:max_date)
        AND u.grid_i >= :min_i AND u.grid_i <= :max_i
        AND u.grid_j >= :min_j AND u.grid_j <= :max_j
        AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < (:rayon_km)
        AND m.id IS NULL
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
      min_date: @campaign.max_age.years.ago,
      max_date: @campaign.min_age.years.ago,
      lat: @vaccination_center.lat,
      lon: @vaccination_center.lon,
      rayon_km: @campaign.max_distance_in_meters / 1000,
      min_i: @covering[:center_cell][:i] - @covering[:dist_cells],
      max_i: @covering[:center_cell][:i] + @covering[:dist_cells],
      min_j: @covering[:center_cell][:j] - @covering[:dist_cells],
      max_j: @covering[:center_cell][:j] + @covering[:dist_cells],
      vaccine_type: @campaign.vaccine_type,
      throttling_rate: @campaign.throttling_rate,
      throttling_interval: @campaign.throttling_interval.ago
    }

    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    ActiveRecord::Base.connection.execute(query).to_a.first
  end
end
