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
      slots_0_days: (slot[:appointment_schedules][:"0_days"]),
      slots_1_days: (slot[:appointment_schedules][:"1_days"]),
      slots_2_days: (slot[:appointment_schedules][:"2_days"]),
      slots_7_days: (slot[:appointment_schedules][:"7_days"]),
      slots_28_days: (slot[:appointment_schedules][:"28_days"]),
      slots_49_days: (slot[:appointment_schedules][:"49_days"]),
      pfizer: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:pfizer]),
      moderna: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:moderna]),
      janssen: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:janssen]),
      astrazeneca: (slot[:vaccine_type] || []).include?(VACCINE_TYPES[:astrazeneca])
    )
  end
end
