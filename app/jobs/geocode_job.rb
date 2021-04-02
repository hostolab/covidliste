class GeocodeJob < ActiveJob::Base
  # Set the Queue as Default
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return if user.address.nil?
    return if user.lat && user.lon
    results = Geocoder.search(user.address)
    begin
      lat = results.first.coordinates[0]
      lon = results.first.coordinates[1]
      user.update(lat: lat, lon: lon)
    rescue
      ## todo: add error reporting
    end
  end
end
