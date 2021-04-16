class GeocodeResourceJob < ApplicationJob
  queue_as :low

  def perform(resource)
    return if resource.nil? || resource.try(:address).nil?

    result = GeocodingService.new(resource.address).call
    resource.update!(result.slice(*resource.attributes.keys.map(&:to_sym))) if result
  rescue => error
    Rails.logger.error(error.message)
  end
end
