module Admin
  class VaccinationCentersController < BaseController
    before_action :set_vaccination_center, only: [:show, :validate]

    def index
      @vaccination_centers = VaccinationCenter.all
    end

    def show
    end

    def new
      @vaccination_center = VaccinationCenter.new
    end

    def create
      @vaccination_center = VaccinationCenter.new(vaccination_center_params)
      @vaccination_center.save
      render action: :new
    end

    def validate
      if @vaccination_center.confirmed_at.nil?
        @vaccination_center.update(confirmed_at: Time.now.utc, confirmer: current_user)
        flash[:success] = "Ce centre a bien été validé"
        redirect_to admin_vaccination_center_path(@vaccination_center)
      else
        flash[:alert] = "Ce centre a déjà été validé !"
        redirect_to admin_vaccination_center_path(@vaccination_center)
      end
    end

    private

    def set_vaccination_center
      @vaccination_center = VaccinationCenter.find(params[:id])
    end

    def vaccination_center_params
      params.require(:vaccination_center).permit(:name, :description, :address, :kind, :pfizer, :moderna, :astrazeneca, :janssen, :phone_number, :lat, :lon)
    end
  end
end
