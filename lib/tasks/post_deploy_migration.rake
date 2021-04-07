namespace :post_deploy_migration do
  desc "Fetch city and zipcode for old users"
  task fill_city_zipcode: :environment do
    User.where(city: nil).where.not(address: nil).find_each do |user|
      begin
        geojson_result = GeocodingService.new(user.address).geojson_result
        properties = geojson_result["features"][0]["properties"]

        # {"label"=>"Rue du Faubourg Saint-Honoré 75008 Paris",
        #  "score"=>0.8268820779220779,
        #  "id"=>"75108_3518",
        #  "name"=>"Rue du Faubourg Saint-Honoré",
        #  "postcode"=>"75008",
        #  "citycode"=>"75108",
        #  "x"=>649436.36,
        #  "y"=>6863883.06,
        #  "city"=>"Paris",
        #  "district"=>"Paris 8e Arrondissement",
        #  "context"=>"75, Paris, Île-de-France",
        #  "type"=>"street",
        #  "importance"=>0.73856}

        # Skip validations with 'update_columns' to be faster
        user.update_columns(
          city: properties["city"],
          zipcode: properties["postcode"]
        )
      rescue => e
        # In case of a geocoding error
      end
    end
  end
end
