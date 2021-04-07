module Admin
  class VaccinationCentersController < BaseController
    before_action :set_vaccination_center, only: %i[show validate edit update destroy]
    before_action :search_params, only: [:index]
    before_action :set_filters, only: [:index]

    def index
      vaccination_centers = VaccinationCenter.all

      ## Query
      query = params.dig(:centers_search, :query)
      if query.present?
        query = query.first
        vaccination_centers = vaccination_centers.search(query)
      end

      ## Filters

      # Kinds
      if @kinds.present?
        kinds_ids = []

        VaccinationCenter::Kinds::ALL.each do |_kind|
          kinds_ids += vaccination_centers.where(kind: _kind) if _kind.in?(@kinds)
        end

        vaccination_centers = vaccination_centers.where(id: kinds_ids)
      end

      # Vaccines
      if @vaccines.present?
        vaccines_ids = []
        vaccines_ids += vaccination_centers.where(pfizer: true).ids if "pfizer".in?(@vaccines)
        vaccines_ids += vaccination_centers.where(moderna: true).ids if "moderna".in?(@vaccines)
        vaccines_ids += vaccination_centers.where(astrazeneca: true).ids if "astrazeneca".in?(@vaccines)
        vaccines_ids += vaccination_centers.where(janssen: true).ids if "janssen".in?(@vaccines)

        vaccination_centers = vaccination_centers.where(id: vaccines_ids)
      end

      # Validation
      if @validations.present?
        if "oui".in?(@validations)
          vaccination_centers = vaccination_centers.where.not(confirmed_at: nil)
        else
          vaccination_centers = vaccination_centers.where(confirmed_at: nil)
        end
      end

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

    def search_params
      params.permit(
        :query,
        kinds: [],
        vaccines: [],
        validations: [],
      )
    end

    def set_filters
      @kinds = search_params[:kinds].to_a.reject(&:blank?)
      @vaccines = search_params[:vaccines].to_a.reject(&:blank?)
      @validations = search_params[:validations].to_a.reject(&:blank?)
    end
  end
end
