class GeocodeUserJob < ActiveJob::Base
  queue_as :low

  def perform(user_id)
    user = User.find_by(id: user_id)
    return if user.nil? || user.address.nil?

    result = GeocodingService.new(user.address).geocode
    user.update(result) if result
  rescue
    # TODO: report error
  end
end
