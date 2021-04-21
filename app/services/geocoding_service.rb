class GeocodingService
  include HTTParty
  base_uri "https://api-adresse.data.gouv.fr"

  def initialize(address)
    @address = address
  end

  def call
    first_result = self.class.get("/search", query: {q: @address, limit: 1}).dig("features")&.first
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
