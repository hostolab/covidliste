class VmdSlot < ApplicationRecord
  validates :center_id, uniqueness: {scope: :last_updated_at}

  OVERBOOKING_FACTOR = 2

  VACCINE_TYPES = {
    pfizer: "Pfizer-BioNTech",
    moderna: "Moderna",
    astrazeneca: "AstraZeneca",
    janssen: "Janssen"
  }.freeze

  def self.build_from_hash(slot, last_updated_at=nil)
    slot.deep_symbolize_keys!
    return if VmdSlot.where(center_id: slot[:internal_id]).where("last_updated_at >= ?", last_updated_at - 1.seconds).any?
    VmdSlot.create(
      center_id: slot[:internal_id],
      url: slot[:url],
      name: slot[:nom],
      department: slot[:departement],
      latitude: begin
        slot[:location][:latitude]
      rescue
        nil
      end,
      longitude: begin
        slot[:location][:longitude]
      rescue
        nil
      end,
      city: begin
        slot[:location][:city]
      rescue
        nil
      end,
      address: begin
        slot[:metadata][:address]
      rescue
        nil
      end,
      phone_number: begin
        slot[:metadata][:phone_number]
      rescue
        nil
      end,
      next_rdv: slot[:prochain_rdv],
      center_type: slot[:type],
      platform: slot[:plateforme],
      slots_count: slot[:appointment_count],
      last_updated_at: last_updated_at,
      pfizer: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:pfizer]),
      moderna: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:moderna]),
      janssen: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:janssen]),
      astrazeneca: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:astrazeneca])
    )
  end

  def self.get_appointment_schedule(slot, key)
    slot[:appointment_schedules].find { |x| x[:name] == key }[:total]
  rescue
    0
  end

  def vaccine_type
    VACCINE_TYPES.each do |k, v|
      return v if send(k)
    end
  end

  def reachable_users(user_alerting_intensity = nil)
    sql = <<~SQL.tr("\n", " ").squish
      with users_stats as (
        select
        u.id as user_id,
        ((SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) / 1.0)::int * 1 as distance_bucket,
        u.alerting_intensity,
        COUNT(a.id) as total_alerts,
        COUNT(m.id) as total_matches
        from users u
        left outer join slot_alerts a on (a.user_id = u.id)
        left outer join matches m on (m.user_id = u.id)
        WHERE
          u.confirmed_at IS NOT NULL
          AND u.anonymized_at is NULL
          AND (u.alerting_intensity >= :user_alerting_intensity or :user_alerting_intensity is null)
          AND u.birthdate between (:min_date) and (:max_date)
          AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < u.max_distance_km
        group by 1,2
      )
      select
        *
        from users_stats
        order by
        alerting_intensity desc,
        total_alerts asc,
        distance_bucket asc,
        total_matches asc
      limit (:limit)
    SQL
    min_age = astrazeneca || janssen ? 55 : 18
    params = {
      min_date: 130.years.ago,
      max_date: min_age.years.ago,
      lat: latitude,
      lon: longitude,
      user_alerting_intensity: user_alerting_intensity,
      limit: slots_7_days * OVERBOOKING_FACTOR
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    User.where(id: ActiveRecord::Base.connection.execute(query).to_a.pluck("user_id"))
  end

  def send_alerts(user_alerting_intensity = nil)
    reachable_users(user_alerting_intensity).each do |user|
      SlotAlert.create(vmd_slot_id: id, user_id: user.id)
    end
  end

  def self.find_slots_for_user(user_id)
    user = User.find(user_id)
    VmdSlot
      .where("last_updated_at >= ?", 11.minutes.ago)
      .where("(pfizer is true or moderna is true) and astrazeneca is false")
      .where("(SQRT(((latitude - ?)*110.574)^2 + ((longitude - ?)*111.320*COS(latitude::float*3.14159/180))^2)) < ? ", user.lat, user.lon, user.max_distance_km)
      .where("slots_count > 10")
      .order("next_rdv asc")
      .limit(100)
  end
end
