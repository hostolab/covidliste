class ReverseGeocodingService
  include HTTParty
  base_uri "https://api-adresse.data.gouv.fr"

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def call
    response = self.class.get("/reverse", query: {lat: @lat, lon: @lon, limit: 1})
    return nil if response.code != 200

    first_result = response.dig("features")&.first
    return nil if first_result.nil?

    Rails.logger.debug(first_result)

    coordinates = first_result.dig("geometry", "coordinates")
    {
      lat: coordinates.second,
      lon: coordinates.first,
      zipcode: first_result.dig("properties", "postcode"),
      city: first_result.dig("properties", "city"),
      geo_citycode: first_result.dig("properties", "citycode"),
      geo_context: first_result.dig("properties", "context")
    }
  end
end
