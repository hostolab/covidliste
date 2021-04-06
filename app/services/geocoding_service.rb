class GeocodingService
  include HTTParty
  base_uri "https://api-adresse.data.gouv.fr/search"

  def initialize(address)
    @address = CGI.escape(address)
    @options = {}
  end

  def geocode
    {
      lat: latlon[1],
      lon: latlon[0],
      postal_code: postal_code
    }
  end

  def geojson_result
    @geojson_result ||= self.class.get("?q=#{@address}&limit=1", @options)
  end

  def latlon
    @latlon ||= geojson_result["features"][0]["geometry"]["coordinates"]
  end

  def postal_code
    @postal_code ||= geojson_result["features"][0]["properties"]["postcode"]
  end
end
