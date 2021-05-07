class VdmService
  include HTTParty
  base_uri "https://vitemadose.gitlab.io/vitemadose"

  VACCINE_TYPES = {
    pfizer: "Pfizer-BioNTech",
    moderna: "Moderna",
    az: "AstraZeneca",
    jj: "Janssen"
  }.freeze

  def next_day_search(lat, lon, rayon_km, vaccine_type = nil)
    results = next_day_slots.filter { |x| distance_from_location(x, lat, lon) <= rayon_km }
    results = results.filter { |x| x["vaccine_type"]&.include?(VACCINE_TYPES[vaccine_type.to_sym]) } if vaccine_type
    results
  end

  def search(lat, lon, rayon_km, vaccine_type = nil)
    results = centres.filter { |x| distance_from_location(x, lat, lon) <= rayon_km }
    results = results.filter { |x| x["vaccine_type"]&.include?(VACCINE_TYPES[vaccine_type.to_sym]) } if vaccine_type
    results
  end

  def data
    @data ||= self.class.get("/info_centres.json")
  end

  def centres
    @centres ||= data.map do |k, v|
      v["centres_disponibles"]
    end.flatten
  end

  def next_day_slots
    @next_day_slots ||= centres.filter { |x| x["appointment_schedules"]["1_days"] > 0 }
  end

  def distance_from_location(x, lat, lon)
    loc = x["location"]
    return 999999 unless loc
    Geocoder::Calculations.distance_between(
      [loc["latitude"], loc["longitude"]],
      [lat, lon],
      {unit: :km}
    )
  end
end
