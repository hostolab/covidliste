module Admin
  class SearchController < BaseController

    def search

      @lat = params[:lat]
      @lon = params[:lon]
      @address = params[:address] || "Paris, France"
      @min_age = (params[:min_age] || 18).to_i
      @max_age = (params[:max_age] || 90).to_i
      @max_distance = params[:max_distance] || 1

      if @address && (@lat.nil? || @lon.nil?)
        geocode_results = Geocoder.search(@address)
        @lat = geocode_results.first.coordinates[0]
        @lon = geocode_results.first.coordinates[1]
      end
      @results = User.select(:lat, :lon, :id).between_age(@min_age, @max_age).near([@lat, @lon], @max_distance, unit: :km)
      @count = @results.size  
    end

  end
end
