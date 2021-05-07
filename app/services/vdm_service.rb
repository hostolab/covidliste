class VdmService
  include HTTParty
  base_uri "https://vitemadose.gitlab.io/vitemadose"

  def same_day_search(lat, lon, rayon_km)
    next_day_slots.filter { |x| distance_from_location(x, lat, lon) <= rayon_km }
  end

  def search(lat, lon, rayon_km)
    filter { |x| distance_from_location(x, lat, lon) <= rayon_km }
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
    Geocoder::Calculations.distance_between(
      [loc["latitude"], loc["longitude"]],
      [lat, lon],
      {unit: :km}
    )
  end
end
