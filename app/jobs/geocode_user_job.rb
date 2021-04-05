class GeocodeUserJob < ActiveJob::Base
  # Set the Queue as Default
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    return if user.address.nil?
    results = Geocoder.search(user.address)
    lat = results.first.coordinates[0]
    lon = results.first.coordinates[1]
    user.update(lat: lat, lon: lon)
  end
  
end
