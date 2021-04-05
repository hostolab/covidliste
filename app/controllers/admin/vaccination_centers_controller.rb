module Admin
  class VaccinationCentersController < BaseController

    def index
      @vaccination_centers = VaccinationCenter.all
    end

    def show
      @vaccination_center = VaccinationCenter.find(params[:id])
    end

    def new
      @vaccination_center = VaccinationCenter.new
    end

    def create
      @vaccination_center = VaccinationCenter.new(vaccination_center_params)
      @vaccination_center.save
      render action: :new
    end

    private

    def vaccination_center_params
      params.require(:vaccination_center).permit(:name, :description, :address, :kind, :pfizer, :moderna, :astrazeneca, :janssen, :phone_number, :lat, :lon)
    end
  end
end
