class VmdSlot < ApplicationRecord
  validates :center_id, uniqueness: {scope: :last_updated_at}

  VACCINE_TYPES = {
    pfizer: "Pfizer-BioNTech",
    moderna: "Moderna",
    astrazeneca: "AstraZeneca",
    janssen: "Janssen"
  }.freeze

  def self.build_from_hash(slot)
    slot.deep_symbolize_keys!
    return if VmdSlot.where(center_id: slot[:internal_id]).where("last_updated_at >= ?", slot[:last_scan_with_availabilities].to_datetime - 1.seconds).any?
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
      last_updated_at: slot[:last_scan_with_availabilities],
      slots_0_days: VmdSlot.get_appointment_schedule(slot, "chronodose"),
      slots_1_days: VmdSlot.get_appointment_schedule(slot, "1_days"),
      slots_2_days: VmdSlot.get_appointment_schedule(slot, "2_days"),
      slots_7_days: VmdSlot.get_appointment_schedule(slot, "7_days"),
      slots_28_days: VmdSlot.get_appointment_schedule(slot, "28_days"),
      slots_49_days: VmdSlot.get_appointment_schedule(slot, "49_days"),
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

  def reachable_users(max_distance = 5, limit = 1000)
    sql = <<~SQL.tr("\n", " ").squish
      with users_stats as (
        select
        u.id as user_id,
        ((SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) / 1.0)::int * 1 as distance_bucket,
        COUNT(a.id) as total_alerts,
        COUNT(m.id) as total_matches
        from users u
        left outer join slot_alerts a on (a.user_id = u.id)
        left outer join matches m on (m.user_id = u.id)
        WHERE
          u.confirmed_at IS NOT NULL
          AND u.anonymized_at is NULL
          AND u.birthdate between (:min_date) and (:max_date)
          AND (SQRT((((:lat) - u.lat)*110.574)^2 + (((:lon) - u.lon)*111.320*COS(u.lat::float*3.14159/180))^2)) < (:max_distance)
        group by 1,2
      )
      select
        user_id,
        distance_bucket,
        total_alerts,
        total_matches
        from users_stats
        order by
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
      max_distance: max_distance,
      limit: limit
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    User.where(id: ActiveRecord::Base.connection.execute(query).to_a.pluck("user_id"))
  end

  def send_alerts(max_distance = 25, limit = nil)
    limit ||= slots_7_days
    users = reachable_users(max_distance, limit)
    users.each do |user|
      SlotAlert.create(vmd_slot_id: id, user_id: user.id)
    end
  end
end
