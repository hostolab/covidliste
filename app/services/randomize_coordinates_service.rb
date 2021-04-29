class RandomizeCoordinatesService
  EARTH_RADIUS = 6378.137

  def initialize(lat, lon, meters_range = 100)
    @lat = lat
    @lon = lon
    @meters_range = meters_range # randomize within +/- METERS
  end

  def call
    dy = rand(-@meters_range..@meters_range) / 1000.0
    dx = rand(-@meters_range..@meters_range) / 1000.0

    new_lat = @lat + (dy / EARTH_RADIUS) * (180 / Math::PI)
    new_lon = @lon + (dx / EARTH_RADIUS) * (180 / Math::PI) / Math.cos(@lat * Math::PI / 180)
    distance = Geocoder::Calculations.distance_between([@lat, @lon], [new_lat, new_lon], {unit: :km})

    {lat: new_lat, lon: new_lon, distance_from_original: distance, dy: dy, dx: dx}
  end
end
