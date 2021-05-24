class VaccinationCentersController < ApplicationController
  def geojson
    geojson_vaccination_centers = VaccinationCenter.confirmed.map do |vaccination_center|
      {
        geometry: {
          type: "Point",
          coordinates: [
            vaccination_center.public_lon,
            vaccination_center.public_lat
          ]
        },
        type: "Feature",
        properties: {
          name: vaccination_center.public_name,
          description: vaccination_center.public_description,
          kind: vaccination_center.public_kind,
          style: {
            radius: 100,
            weight: 5,
            opacity: 0.8,
            fillOpacity: 0.5,
            color: "#3388ff",
            fillColor: vaccination_center.map_color
          },
          popupContent: "<strong>#{vaccination_center.public_name}</strong><br />#{vaccination_center.public_description}<br /><em>#{vaccination_center.public_location}</em>"
        }
      }
    end

    geojson = {
      type: "FeatureCollection",
      features: geojson_vaccination_centers
    }

    render json: geojson
  end

  private

  def skip_pundit?
    true
  end
end
