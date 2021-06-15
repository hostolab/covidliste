module Admin
  class VaccinationCentersController < BaseController
    before_action :set_vaccination_center, except: [:index, :new, :create]
    before_action :search_params, only: [:index]
    before_action :set_filters, only: [:index]

    helper_method :sort_column, :sort_direction

    def index
      vaccination_centers = policy_scope(VaccinationCenter).all

      ## Query
      query = params.dig(:centers_search, :query)&.first
      if query.present?
        vaccination_centers = vaccination_centers.global_search(query)
      end

      ## Filters

      # Kinds
      if @kinds.present?
        kinds_ids = []

        VaccinationCenter::Kinds::ALL.each do |this_kind|
          kinds_ids += vaccination_centers.where(kind: this_kind) if this_kind.in?(@kinds)
        end

        vaccination_centers = vaccination_centers.where(id: kinds_ids)
      end

      # Validation
      if @validations.present?
        vaccination_centers = "oui".in?(@validations) ? vaccination_centers.where.not(confirmed_at: nil) : vaccination_centers.where(confirmed_at: nil)
      end

      respond_to do |format|
        format.html {
          @pagy_vaccination_centers, @vaccination_centers = pagy(vaccination_centers.order(ActiveRecord::Base.sanitize_sql("#{sort_column} #{sort_direction}")))
        }
        format.csv { send_data vaccination_centers.includes(:confirmer, partners: [:partner_external_accounts]).order(id: :asc).to_csv, filename: "vaccination_centers-#{Date.today}.csv" }
      end
    end

    def show
    end

    def validate
      if @vaccination_center.confirmed_at.nil?
        @vaccination_center.confirmed_at = Time.now.utc
        @vaccination_center.confirmer = current_user
        if @vaccination_center.save(context: :validation_by_admin)
          SendVaccinationCenterConfirmationEmailJob.perform_later(@vaccination_center.id)
          flash[:success] = "Ce centre a bien été validé"
        else
          flash[:alert] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
        end
      else
        flash[:alert] = "Ce centre a déjà été validé !"
      end
      redirect_to admin_vaccination_center_path(@vaccination_center)
    end

    def enable
      if @vaccination_center.update(disabled_at: nil)
        flash[:success] = "Ce centre est maintenant activé"
      else
        error = @vaccination_center.errors.full_messages.join(", ")
        flash[:alert] = "Une erreur est survenue: #{error}"
      end

      redirect_to admin_vaccination_center_path(@vaccination_center)
    end

    def disable
      if @vaccination_center.update(disabled_at: Time.now.utc)
        flash[:success] = "Ce centre est maintenant désactivé"
      else
        error = @vaccination_center.errors.full_messages.join(", ")
        flash[:alert] = "Une erreur est survenue: #{error}"
      end

      redirect_to admin_vaccination_center_path(@vaccination_center)
    end

    def edit
    end

    def update
      if !@vaccination_center.visible_optin && ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["visible_optin"])
        @vaccination_center.visible_optin_at = Time.now.utc
      elsif @vaccination_center.visible_optin && !ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["visible_optin"])
        @vaccination_center.visible_optin_at = nil
      end
      if !@vaccination_center.media_optin && ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["media_optin"])
        @vaccination_center.media_optin_at = Time.now.utc
      elsif @vaccination_center.media_optin && !ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["media_optin"])
        @vaccination_center.media_optin_at = nil
      end
      @vaccination_center.assign_attributes(vaccination_center_params)
      if @vaccination_center.save
        flash[:success] = "Ce lieu a bien été modifié"
        redirect_to admin_vaccination_center_path(@vaccination_center)
      else
        flash[:alert] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
        render action: :edit
      end
    end

    def destroy
      @vaccination_center.partners.destroy_all

      if @vaccination_center.destroy
        flash[:success] = "Ce centre a bien été supprimé"
        redirect_to admin_vaccination_centers_path
      else
        flash[:error] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
        redirect_to admin_vaccination_center_path(@vaccination_center)
      end
    end

    def add_partner
      query_email = params.require(:new_partner_email).permit(:email)[:email]

      partner = Partner.find_by(email: query_email)

      if partner.present?
        if partner.in?(@vaccination_center.partners)
          flash[:error] = "#{partner.email} fait déjà partie de cette organisation."
        else
          @vaccination_center.partners << partner
          flash[:success] = "#{partner.email} fait désormais partie de cette organisation."
        end
      else
        flash[:error] = "Professionnel de santé introuvable. #{query_email} doit d’abord créer un compte sur #{partenaires_inscription_url}"
      end

      redirect_to admin_vaccination_center_path(@vaccination_center)
    end

    private

    def set_vaccination_center
      # TODO: go for @vaccination_center = authorize(VaccinationCenter.find(params[:id])) when
      # https://github.com/varvet/pundit/issues/666 is fixed.
      @vaccination_center = VaccinationCenter.find(params[:id])
      authorize(@vaccination_center)
    end

    def vaccination_center_params
      params.require(:vaccination_center).permit(:name, :description, :finess, :address, :kind, :phone_number, :lat, :lon)
    end

    def vaccination_center_optin_params
      params.require(:vaccination_center).permit(:visible_optin, :media_optin)
    end

    def sort_column
      VaccinationCenter.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction].to_sym : :desc
    end

    def search_params
      params.permit(
        :query,
        kinds: [],
        validations: []
      )
    end

    def set_filters
      @kinds = search_params[:kinds].to_a.reject(&:blank?)
      @validations = search_params[:validations].to_a.reject(&:blank?)
    end
  end
end
