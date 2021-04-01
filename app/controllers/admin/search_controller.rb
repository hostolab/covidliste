include ActionView::Helpers::NumberHelper
module Admin
  class SearchController < BaseController

    before_action :require_role!

    def search
      @user = current_user
      @users_count = number_with_delimiter(User.count, locale: :fr)

      @lat = '48.8534'
      @lon = '2.3488'
      @address = 'Paris, France'
      @distance = 50
      @age_min = 1
      @age_max = 200
      unless params[:map].blank?
        unless params[:map][:age_min].blank?
          @age_min = params[:map][:age_min].to_i
        end
        unless params[:map][:age_max].blank?
          @age_max = params[:map][:age_max].to_i
        end
        unless params[:map][:distance].blank?
          @distance = params[:map][:distance].to_i
        end
        unless params[:map][:address].blank?
          if !params[:map][:lat].blank? && !params[:map][:lon].blank?
            @lat = params[:map][:lat]
            @lon = params[:map][:lon]
            @address = params[:map][:address]
          else
            result = Geocoder.search(params[:map][:address])
            if result&.first
              @lat = result.first.data['lat'].to_f.round(2).to_s
              @lon = result.first.data['lon'].to_f.round(2).to_s
              @address = result.first.address
            else
              flash.now.alert = "Adresse #{params[:map][:address]} non trouvée."
            end
          end
        end
      end

      min_date = Date.today - @age_max.years
      max_date = Date.today - @age_min.years

      volunteers_limit = 2000
      box = Geocoder::Calculations.bounding_box([@lat, @lon], @distance)
      @bounds = [
        [box[0], box[1]],
        [box[2], box[3]],
      ]

      @users_count = User
              .where.not(lat: nil)
              .where.not(lon: nil)
              .where(lat: [box[0]..box[2]])
              .where(lon: [box[1]..box[3]])
              .where("birthdate BETWEEN ? AND ?", min_date, max_date)
              .limit(volunteers_limit + 100) # extra security
              .count

      # TODO IMPLEMENT DISTANCE IN RESULTS WITH Geocoder::Calculations.distance_between(start_address_coordinates, destination_coordinates)
      @users = User
               .where.not(lat: nil)
               .where.not(lon: nil)
               .where(lat: [box[0]..box[2]])
               .where(lon: [box[1]..box[3]])
               .where(birthdate: min_date..max_date)
               .limit(volunteers_limit + 100) # extra security
    end

    def require_role!
      authenticate_user!
      return if current_user.has_role?(:admin)
      flash[:alert] = "Vous n'êtes pas autorisé à accéder à cette page !"
      redirect_to(root_path)
    end
  end
end
