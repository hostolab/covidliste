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
            color: vaccination_center.visible_optin ? "#2c1b2d" : "#8c588f",
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

  def missing_users_geojson
    departments_geojson = JSON.parse(File.read("app/assets/geojson/departements.geojson"))

    sql = <<~SQL.tr("\n", " ").squish
      SELECT
        v.geo_context,
        SUM(c.available_doses)-SUM(c.matches_confirmed_count)+SUM(c.canceled_doses) as doses
        FROM campaigns c
        left join vaccination_centers v on (c.vaccination_center_id = v.id)
        WHERE c.starts_at >= :min_date
        AND c.vaccine_type NOT IN ('astrazeneca', 'janssen')
        AND (
          (c.status = 1 AND c.available_doses > c.matches_confirmed_count)
          OR
          (c.status = 2 AND c.canceled_doses > 0)
        )
        GROUP BY 1
    SQL
    params = {
      min_date: Date.today - 7.days
    }
    query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    results = ActiveRecord::Base.connection.execute(query).to_a

    departments = {}
    results.each do |result|
      if (m = result["geo_context"].match(/^([\dAB]{2,3}),/))
        department_code = m[1]
        departments[department_code] = {count: 0, name: result["geo_context"]} unless departments[department_code]
        departments[department_code][:count] += result["doses"]
      end
    end

    departments_geojson["features"].each do |feature|
      feature["properties"]["style"] = {
        weight: 1,
        color: "#8c588f",
        opacity: 0.5,
        fillColor: "#8c588f",
        fillOpacity: 0.01
      }
      feature["properties"]["popupContent"] = "<strong>#{feature["properties"]["nom"]}</strong><br /><em>0 doses n'ont pas trouvé preneur dans les 7 derniers jours</em>"
      if departments[feature["properties"]["code"]]
        department = departments[feature["properties"]["code"]]
        if department[:count] > 0
          # convert doses (between 1-infinite) into a number between 0.1 and 0.95
          # to scale your variable x into a range [a,b] you can use:
          # f(x) = ( b - a ) * ( ( x - xmin ) / ( xmax - xmin ) ) + a
          x = (department[:count] > 200 ? 200 : department[:count]).to_f # capping to 200 for calculation
          xmin = 1.to_f
          xmax = 300.to_f
          b = 0.95.to_f
          a = 0.1.to_f
          y = (b - a) * ((x - xmin) / (xmax - xmin)) + a

          feature["properties"]["style"] = {
            weight: 1,
            color: "#8c588f",
            opacity: 0.5,
            fillColor: "#8c588f",
            fillOpacity: y.round(2)
          }
          feature["properties"]["popupContent"] = "<strong>#{feature["properties"]["nom"]}</strong><br /><em>#{department[:count]} doses n'ont pas trouvé preneur dans les 7 derniers jours</em>"
        end
      end
    end

    render json: departments_geojson
  end

  private

  def skip_pundit?
    true
  end
end
