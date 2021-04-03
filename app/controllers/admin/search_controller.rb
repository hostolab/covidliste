include ActionView::Helpers::NumberHelper
module Admin
  class SearchController < BaseController

    before_action :require_role!
    helper_method :sort_column, :sort_direction

    def search
      @user = current_user
      @users_count = Rails.cache.fetch(:users_count, expires_in: 1.minute) do
        number_with_delimiter(User.count, locale: :fr)
      end

      @lat = '48.8534'
      @lon = '2.3488'
      @address = 'Paris, France'
      @distance = 50
      @age_min = 1
      @age_max = 200
      @sort_column = sort_column
      @sort_direction = sort_direction
      unless params[:age_min].blank?
        @age_min = params[:age_min].to_i
      end
      unless params[:age_max].blank?
        @age_max = params[:age_max].to_i
      end
      unless params[:distance].blank?
        @distance = params[:distance].to_i
      end
      unless params[:address].blank?
        if !params[:lat].blank? && !params[:lon].blank?
          @lat = params[:lat]
          @lon = params[:lon]
          @address = params[:address]
        else
          result = Geocoder.search(params[:address])
          if result&.first
            @lat = result.first.data['lat'].to_f.round(2).to_s
            @lon = result.first.data['lon'].to_f.round(2).to_s
            @address = result.first.address
          else
            flash.now.alert = "Adresse #{params[:address]} non trouvée."
          end
        end
      end

      min_date = Date.today - @age_max.years
      max_date = Date.today - @age_min.years

      volunteers_limit = 500
      box = Geocoder::Calculations.bounding_box([@lat, @lon], @distance)
      @bounds = [
        [box[0], box[1]],
        [box[2], box[3]],
      ]

      @search_users_count = User
              .where.not(lat: nil)
              .where.not(lon: nil)
              .where(lat: [box[0]..box[2]])
              .where(lon: [box[1]..box[3]])
               .where(birthdate: min_date..max_date)
              .limit(volunteers_limit + 100) # extra security
              .count

      @users = User
               .where.not(lat: nil)
               .where.not(lon: nil)
               .where(lat: [box[0]..box[2]])
               .where(lon: [box[1]..box[3]])
               .where(birthdate: min_date..max_date)
               .order("#{sort_column} #{sort_direction}")
               .limit(volunteers_limit) # extra security
    end

    private

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def require_role!
      authenticate_user!
      return if current_user.has_role?(:admin)
      flash[:alert] = "Vous n'êtes pas autorisé à accéder à cette page !"
      redirect_to(root_path)
    end
  end
end
