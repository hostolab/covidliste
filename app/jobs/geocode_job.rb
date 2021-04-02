class GeocodeJob < ActiveJob::Base
  # Set the Queue as Default
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return if user.address.nil?
    return if user.lat && user.lon
    ## geocode
  end
end
