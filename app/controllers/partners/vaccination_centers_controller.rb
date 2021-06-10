module Partners
  class VaccinationCentersController < ApplicationController
    before_action :define_as_page_pro
    before_action :authenticate_partner!
    before_action :find_vaccination_center, only: [:show, :update]
    before_action :authorize!, except: [:index, :new, :create, :update]

    helper_method :sort_column, :sort_direction

    def index
      @vaccination_centers = current_partner.vaccination_centers.includes([:partner_vaccination_centers, :partners])
      @unconfirmed_vaccination_centers = current_partner.unconfirmed_vaccination_centers
      @external_accounts = current_partner.partner_external_accounts.order(id: :desc)
    end

    def show
    end

    def new
      @vaccination_center = VaccinationCenter.new
    end

    def create
      @vaccination_center = VaccinationCenter.new(vaccination_center_params)
      @vaccination_center.visible_optin_at = Time.now.utc if ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["visible_optin"])
      @vaccination_center.media_optin_at = Time.now.utc if ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["media_optin"])
      @vaccination_center.save
      @partner_vaccination_center = PartnerVaccinationCenter.new(partner: current_partner,
                                                                 vaccination_center: @vaccination_center)
      @partner_vaccination_center.save
      prepare_phone_number
      render action: :new
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
      if @vaccination_center.update(vaccination_center_params)
        flash[:success] = "Ce centre a bien été modifié"
        render :show
      else
        flash[:success] = "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
        render :show
      end
    end

    def prepare_phone_number
      @vaccination_center.phone_number = @vaccination_center.human_friendly_phone_number
    end

    private

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
      params.require(:vaccination_center).permit(:name, :description, :finess, :address, :kind, :phone_number)
    end

    def vaccination_center_optin_params
      params.require(:vaccination_center).permit(:visible_optin, :media_optin)
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
