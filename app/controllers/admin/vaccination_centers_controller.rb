module Admin
  class VaccinationCentersController < BaseController
    before_action :set_vaccination_center, only: %i[show validate edit update destroy]

    def index
      vaccination_centers = VaccinationCenter.all

      respond_to do |format|
        format.html {
          @pagy_vaccination_centers, @vaccination_centers = pagy(vaccination_centers)
        }
        format.csv { send_data vaccination_centers.to_csv, filename: "vaccination_centers-#{Date.today}.csv" }
      end
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
        if @vaccination_center.update(confirmed_at: Time.now.utc, confirmer: current_user)
          flash[:success] = "Ce centre a bien été validé"
        else
          flash[:alert] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
        end
      else
        flash[:alert] = "Ce centre a déjà été validé !"
      end
      redirect_to admin_vaccination_center_path(@vaccination_center)
    end

    def edit
    end

    def update
      if @vaccination_center.update(vaccination_center_params)
        flash[:success] = "Ce centre a bien été modifié"
      else
        flash[:alert] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
      end

      redirect_to admin_vaccination_center_path(@vaccination_center)
    end

    def destroy
      @vaccination_center.partners.destroy_all

      if @vaccination_center.destroy
        flash[:success] = "Ce centre a bien été supprimé"
        redirect_to admin_vaccination_centers_path
      else
        flash[:alert] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
        redirect_to admin_vaccination_center_path(@vaccination_center)
      end
    end

    private

    def set_vaccination_center
      @vaccination_center = VaccinationCenter.find(params[:id])
    end

    def vaccination_center_params
      params.require(:vaccination_center).permit(:name, :description, :address, :kind, :pfizer, :moderna, :astrazeneca,
        :janssen, :phone_number, :lat, :lon)
    end
  end
end
