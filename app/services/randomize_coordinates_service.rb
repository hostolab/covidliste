class RandomizeCoordinatesService
  EARTH_RADIUS = 6378.137
  METERS_RANGE = 100 # randomize within +/- METERS

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def call
    dy = rand(-METERS_RANGE..METERS_RANGE) / 1000.0
    dx = rand(-METERS_RANGE..METERS_RANGE) / 1000.0

    new_lat = @lat + (dy / EARTH_RADIUS) * (180 / Math::PI)
    new_lon = @lon + (dx / EARTH_RADIUS) * (180 / Math::PI) / Math.cos(@lat * Math::PI / 180)
    distance = Geocoder::Calculations.distance_between([@lat, @lon], [new_lat, new_lon], {unit: :km})

    {lat: new_lat, lon: new_lon, distance_from_original: distance, dy: dy, dx: dx}
  end
end
