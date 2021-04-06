module Partners
  class VaccinationCentersController < ApplicationController
    before_action :authenticate_partner!
    helper_method :sort_column, :sort_direction

    def index
      @vaccination_centers = current_partner.vaccination_centers
      @unconfirmed_vaccination_centers = current_partner.unconfirmed_vaccination_centers
    end

    def show
      unless current_partner.vaccination_centers.exists?(params[:id])
        redirect_to(partners_vaccination_centers_path) && return
      end

      @vaccination_center = VaccinationCenter.find(params[:id])
      redirect_to(partners_vaccination_centers_path) && return unless @vaccination_center.confirmed?
    end

    def new
      @vaccination_center = VaccinationCenter.new
    end

    def create
      @vaccination_center = VaccinationCenter.new(vaccination_center_params)
      @vaccination_center.save
      @partner_vaccination_center = PartnerVaccinationCenter.new(partner: current_partner,
                                                                 vaccination_center: @vaccination_center)
      @partner_vaccination_center.save
      render action: :new
    end

    private

    def vaccination_center_params
      params.require(:vaccination_center).permit(:name, :description, :address, :kind, :pfizer, :moderna, :astrazeneca,
        :janssen, :phone_number, :lat, :lon)
    end

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
  end
end
