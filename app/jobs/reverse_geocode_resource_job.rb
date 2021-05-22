class ReverseGeocodeResourceJob < ApplicationJob
  queue_as :low

  def perform(resource)
    return if resource.nil? || resource.try(:lat).nil? || resource.try(:lon).nil?

    result = ReverseGeocodingService.new(resource.lat, resource.lon).call
    resource.try(:skip_reverse_geocode=, true)
    resource.update!(result.slice(*resource.attributes.keys.map(&:to_sym))) if result
  rescue => error
    Rails.logger.error(error.message)
  end
end
