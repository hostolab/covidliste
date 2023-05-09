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
      if Flipper.enabled?(:pause_service) or ENV["STATIC_SITE_GEN"]
        flash.now[:error] = "Le service est en pause. La création de lieux de vaccination est désactivée."
        return render action: :new, status: :unprocessable_entity
      end
      @vaccination_center.visible_optin_at = Time.now.utc if ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["visible_optin"])
      @vaccination_center.media_optin_at = Time.now.utc if ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["media_optin"])
      @same_existing_vaccination_centers = check_if_already_exists(@vaccination_center, :address, :phone_number, :finess)
      unless @same_existing_vaccination_centers && @vaccination_center.confirmation_creation.to_i.zero?
        @vaccination_center.save
        @partner_vaccination_center = PartnerVaccinationCenter.new(partner: current_partner,
                                                                   vaccination_center: @vaccination_center)
        @partner_vaccination_center.save
        prepare_phone_number
      end
      render action: :new
    end

    def update
      if !@vaccination_center.visible_optin && ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["visible_optin"])
        @vaccination_center.visible_optin_at = Time.now.utc
      elsif @vaccination_center.visible_optin && (ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["visible_optin"]) == false)
        @vaccination_center.visible_optin_at = nil
      end
      if !@vaccination_center.media_optin && ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["media_optin"])
        @vaccination_center.media_optin_at = Time.now.utc
      elsif @vaccination_center.media_optin && (ActiveRecord::Type::Boolean.new.cast(vaccination_center_optin_params["media_optin"]) == false)
        @vaccination_center.media_optin_at = nil
      end
      flash[:success] = if @vaccination_center.update(vaccination_center_params)
        "Ce lieu a bien été modifié"
      else
        "Une erreur est survenue : #{@vaccination_center.errors.full_messages.join(", ")}"
      end
      render :show
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
      params.require(:vaccination_center).permit(:name, :description, :finess, :address, :kind, :phone_number, :confirmation_creation)
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

    def check_if_already_exists(instance, *attributes)
      corresponding_centers = []
      vaccination_centers = VaccinationCenter.all
      instance_attributes = attributes.map { |attr| instance.send(attr) }
      vaccination_centers.each do |vaccination_center|
        corresponding_centers << vaccination_center if vaccination_center.slice(*attributes).map { |_k, v| v }.intersection(instance_attributes).present?
      end
      corresponding_centers.empty? ? false : corresponding_centers
    end
  end
end
