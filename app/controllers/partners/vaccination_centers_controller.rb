module Partners
  class VaccinationCentersController < ApplicationController
    before_action :authenticate_partner!
    before_action :find_vaccination_center, only: [:show]
    before_action :authorize!, except: [:index, :new, :create]

    helper_method :sort_column, :sort_direction

    def index
      @vaccination_centers = current_partner.vaccination_centers
      @unconfirmed_vaccination_centers = current_partner.unconfirmed_vaccination_centers
    end

    def show
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
      prepare_phone_number
      render action: :new
    end

    private

    def prepare_phone_number
      @vaccination_center.phone_number = @vaccination_center.human_friendly_phone_number
    end

    def find_vaccination_center
      @vaccination_center = VaccinationCenter.find(params[:id])

      unless @vaccination_center.active?
        flash[:error] = "Votre centre n'a pas encore été approuvé par Covidliste"
        redirect_to(partners_vaccination_centers_path)
      end
    end

    def authorize!
      unless @vaccination_center.partners.include?(current_partner)
        flash[:error] = "Vous ne pouvez pas accéder à ce centre"
        redirect_to(partners_vaccination_centers_path)
      end
    end

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

    def skip_pundit?
      # TODO add a real policy
      true
    end
  end
end
