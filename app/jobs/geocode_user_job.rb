class GeocodeUserJob < ActiveJob::Base
  queue_as :low

  def perform(user)
    return if user.address.nil?

    result = GeocodingService.new(user.address).geocode
    user.update(result) if result
  rescue
    # TODO: report error
  end
end
