include ActionView::Helpers::NumberHelper
class PartnersController < ApplicationController

  before_action :require_role!
  helper_method :sort_column, :sort_direction

  def search
    @pertner = current_user # TODO FIXME Use partner devise

    @name = 'Centre de Vaccination' # TODO FIXME Name of vaccination_center
    @lat = '48.8534' # TODO FIXME Lon of vaccination_center
    @lon = '2.3488' # TODO FIXME Lat of vaccination_center
    @address = 'Paris, France' # TODO FIXME Address of vaccination_center

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

    min_date = Date.today - @age_max.years
    max_date = Date.today - @age_min.years

    volunteers_limit = 500
    @max_distance = 1 # default
    [1, 2, 3, 5, 8, 10, 20, 30, 50, 70, 100, 150, 200].each do |d| # trying to find the optimal distance
      box = Geocoder::Calculations.bounding_box([@lat, @lon], d)
      users_count = User
                    .where.not(lat: nil)
                    .where.not(lon: nil)
                    .where(lat: [box[0]..box[2]])
                    .where(lon: [box[1]..box[3]])
                    .limit(volunteers_limit + 100) # extra security
                    .count
      if users_count > volunteers_limit # Limit to 500 volunteers max
        break
      end
      @max_distance = d
    end

    if @distance > @max_distance
      @distance = @max_distance
    end

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

    @search_users_count_by_age = {
      '< 59 ans' => @users.select{|x| x.birthdate.between?((Date.today - 59.years), (Date.today - 0.years))}.size,
      '59 - 69 ans' => @users.select{|x| x.birthdate.between?((Date.today - 70.years), (Date.today - 59.years))}.size,
      '70+ ans' => @users.select{|x| x.birthdate.between?((Date.today - 200.years), (Date.today - 70.years))}.size,
    }

  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def require_role!
    # TODO FIXME MIGRATE TO DEVISE PARTNER
    authenticate_user!
    return if current_user.has_role?(:partner)
    flash[:alert] = "Vous n'êtes pas autorisé à accéder à cette page !"
    redirect_to(root_path)
  end
end
