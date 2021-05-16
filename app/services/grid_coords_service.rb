class GridCoordsService
  DEFAULT_ZOOM_LEVEL = 15
  EARTH_RADIUS = 6378137.0
  EARTH_CIRCUMFERENCE = 2 * Math::PI * EARTH_RADIUS

  def initialize(lat, lon)
    @lat = lat.to_f
    @lon = lon.to_f
  end

  def get_cell
    lat_rad = @lat / 180.0 * Math::PI
    n = 2.0**DEFAULT_ZOOM_LEVEL
    i = ((@lon + 180.0) / 360.0 * n).to_i
    j = ((1.0 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2.0 * n).to_i

    {i: i, j: j}
  end

  def get_cell_size
    lat_rad = @lat / 180 * Math::PI
    EARTH_CIRCUMFERENCE * Math.cos(lat_rad) / (2.0**DEFAULT_ZOOM_LEVEL)
  end

  def get_covering(distance_in_m)
    cell_size = get_cell_size
    n_cells = (distance_in_m / cell_size).ceil
    cell = get_cell

    {center_cell: cell, dist_cells: n_cells, cell_size_meters: cell_size}
  end
end
