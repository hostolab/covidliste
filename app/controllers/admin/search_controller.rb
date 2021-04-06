module Admin
  class SearchController < BaseController

    def search
      @age_bin = 10
      @lat = params[:lat]
      @lon = params[:lon]
      @address = params[:address] || "Paris, France"
      @min_age = (params[:min_age] || 18).to_i
      @max_age = (params[:max_age] || 90).to_i
      @max_distance = [50, (params[:max_distance] || 1).to_f].min

      if @address.present? && (@lat.nil? || @lon.nil?)
        geocode_results = Geocoder.search(@address)
        if geocode_results.present?
          @lat = geocode_results.first.coordinates[0]
          @lon = geocode_results.first.coordinates[1]
        end
      end
      @results = User.select(:lat, :lon, :id, :birthdate).between_age(@min_age, @max_age).near([@lat, @lon], @max_distance, unit: :km)
      @total_count = @results.size
      @count_by_age = @results.group_by {|x| @age_bin * (x.age / @age_bin).to_i }.map {|k, v| ["#{k}-#{k + @age_bin - 1}", v.size]}.sort_by{|x| x[0]}
      @results = @results.limit(500)
    end

  end
end
