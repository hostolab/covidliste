class GridCoordsService
  DEFAULT_ZOOM_LEVEL = 15

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def get_cell
    lat_rad = @lat/180 * Math::PI
    n = 2.0 ** DEFAULT_ZOOM_LEVEL
    i = ((@lon + 180.0) / 360.0 * n).to_i
    j = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n).to_i

    {:i => i, :j => j}
  end
end
