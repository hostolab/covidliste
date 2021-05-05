class ReachableUsersService
  def initialize(campaign)
    @campaign = campaign
    @vaccination_center = campaign.vaccination_center
    @ranking_method = campaign.ranking_method
    @covering = ::GridCoordsService.new(@vaccination_center.lat, @vaccination_center.lon).get_covering(@campaign.max_distance_in_meters)
  end

  def get_users(limit = nil)
    return get_users_with_v2(limit) if @ranking_method == "v2"
    get_users_with_random(limit)
  end

  def get_vaccination_center_grid_query
    cells = @covering[:cells]
    "(grid_i, grid_j) IN ((" + cells.map { |sub| sub.join(",") }.join("),(") + "))"
  end

  def get_users_with_v2(limit = nil)
    sql = <<~SQL.tr("\n", " ").squish
      with reachable_users as (
        SELECT
        u.id as user_id,
        (SQRT( ((:vc_grid_i - u.grid_i) * :grid_cell_size)^2 + ((:vc_grid_j - u.grid_j) * :grid_cell_size)^2 )) as distance
        FROM users u
        WHERE u.confirmed_at IS NOT NULL
        AND u.anonymized_at is NULL
        AND u.birthdate between (:min_date) and (:max_date)
        AND grid_i IN (:cells_i)
        AND grid_j IN (:cells_j)
        AND (SQRT( ((:vc_grid_i - u.grid_i))^2 + ((:vc_grid_j - u.grid_j))^2 ) <= :dist_cells)
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
        SUM(case when m.refused_at is not null and vaccine_type = (:vaccine_type) then 1 else 0 end) as vaccine_refusals_count,
        SUM(case when m.refused_at is not null then 1 else 0 end) as total_refusals_count
        from reachable_users r
        inner join users u on (r.user_id = u.id)
        left outer join matches m on (m.user_id = r.user_id)
        left outer join campaigns c on (c.id = m.campaign_id and c.status != 2)
        group by 1,2,3
        having
         (
           SUM(case when m.confirmed_at is not null then 1 else 0 end) <= 0
           AND (MAX(m.created_at) <= (:last_match_allowed_at) or MAX(m.created_at) is null)
         )
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
      cells_i: @covering[:cells_i],
      cells_j: @covering[:cells_j],
      vc_grid_i: @covering[:center_cell][:i],
      vc_grid_j: @covering[:center_cell][:j],
      dist_cells: @covering[:dist_cells],
      grid_cell_size: @covering[:cell_size_meters] / 1000.0,
      vaccine_type: @campaign.vaccine_type,
      limit: limit,
      last_match_allowed_at: Match::NO_MORE_THAN_ONE_MATCH_PER_PERIOD.ago
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    User.where(id: ActiveRecord::Base.connection.execute(query).to_a.pluck("user_id"))
  end

  def get_users_with_random(limit = nil)
    User
      .confirmed
      .active
      .between_age(@campaign.min_age, @campaign.max_age)
      .where("grid_i IN (?)", @covering[:cells_i])
      .where("grid_j IN (?)", @covering[:cells_j])
      .where("SQRT( ((? - grid_i))^2 + ((? - grid_j))^2 ) <= ?", @covering[:center_cell][:i], @covering[:center_cell][:j], @covering[:dist_cells])
      .where("id not in (
      select user_id from matches m inner join campaigns c on (c.id = m.campaign_id)
      where m.user_id is not null
      and ((m.created_at >= ? and c.status != 2) or (m.confirmed_at is not null))
      )", Match::NO_MORE_THAN_ONE_MATCH_PER_PERIOD.ago) # exclude user_id that have been matched in the last 24 hours, or confirmed
      .order("RANDOM()")
      .limit(limit)
  end

  def get_users_count
    sql = <<~SQL.tr("\n", " ").squish
      SELECT
        COUNT(DISTINCT u.id) as count
        FROM users u
        left outer join matches m on (m.user_id = u.id and m.confirmed_at is not null)
        WHERE u.confirmed_at IS NOT NULL
        AND u.anonymized_at is NULL
        AND u.birthdate between (:min_date) and (:max_date)
        AND u.grid_i IN (:cells_i)
        AND u.grid_j IN (:cells_j)
        AND (SQRT( ((:vc_grid_i - u.grid_i))^2 + ((:vc_grid_j - u.grid_j))^2 ) <= :dist_cells)
        AND m.id IS NULL
    SQL
    params = {
      min_date: @campaign.max_age.years.ago,
      max_date: @campaign.min_age.years.ago,
      cells_i: @covering[:cells_i],
      cells_j: @covering[:cells_j],
      vc_grid_i: @covering[:center_cell][:i],
      vc_grid_j: @covering[:center_cell][:j],
      dist_cells: @covering[:dist_cells],
      vaccine_type: @campaign.vaccine_type
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    ActiveRecord::Base.connection.execute(query).to_a.first["count"].to_i
  end
end
