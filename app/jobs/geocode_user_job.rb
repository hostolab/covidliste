class GeocodeUserJob < ActiveJob::Base
  # Set the Queue as Default
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return if user.address.nil?
    return unless user.lat.nil? || user.lon.nil?

    result = GeocodingService.new(user.address).geocode
    user.update(lat: result[:lat], lon: result[:lon]) if result
  rescue
    # TODO: report error
  end
end
