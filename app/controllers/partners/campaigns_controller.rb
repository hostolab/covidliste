module Partners
  class CampaignsController < ApplicationController
    before_action :authenticate_partner!
    before_action :find_vaccination_center, except: [:show, :update]
    before_action :find_campaign, only: [:show, :update]
    before_action :authorize!

    def show
      respond_to do |format|
        format.html
        format.csv do
          send_data @campaign.to_csv, type: "text/csv", filename: "campagne_#{@campaign.id}.csv", disposition: :attachment
        end
      end
    end

    def new
      @campaign = @vaccination_center.build_campaign_smart_defaults
      render "new"
    end

    def create
      @campaign = @vaccination_center.campaigns.build(create_params)
      @campaign.partner = current_partner

      if @campaign.save
        @campaign.update(name: "Campagne ##{@campaign.id} du #{@campaign.created_at.strftime("%d/%m/%Y")}")
        render json: {campaign: @campaign, redirect_to: partners_campaign_url(@campaign)}
      else
        @campaign.max_distance_in_meters = @campaign.max_distance_in_meters / 1000 if request.format.html?
        render json: {errors: @campaign.errors}, status: 400
      end
    end

    def update
      if params[:cancel] == "true" && @campaign.running?
        @campaign.canceled!
        flash[:notice] = "La campagne vient d'être interrompue."
        redirect_to partners_campaign_path(@campaign)
      end
    end

    def simulate_reach
      vaccine_type = simulate_params[:vaccine_type]
      available_doses = simulate_params[:available_doses]
      campaign = Campaign.new(simulate_params.merge({vaccination_center: @vaccination_center}))
      reach = campaign.reachable_users_count
      render json: {
        reach: reach,
        enough: reach >= (Vaccine.minimum_reach_to_dose_ratio(vaccine_type) * available_doses),
        minimum_reach_to_dose_ratio: Vaccine.minimum_reach_to_dose_ratio(vaccine_type)
      }
    end

    private

    def authorize!
      return if @vaccination_center.can_be_accessed_by?(nil, current_partner)

      flash[:error] = "Vous ne pouvez pas accéder à ce lieu de vaccination"
      redirect_to partners_vaccination_centers_path
    end

    def find_campaign
      @campaign = Campaign.find(params[:id])
      @vaccination_center = @campaign.vaccination_center
    end

    def find_vaccination_center
      @vaccination_center = VaccinationCenter.find(params[:vaccination_center_id])

      if !@vaccination_center.active?
        flash[:error] = "Votre centre n'a pas encore été validé par l'équipe Covidliste."
        redirect_to partners_vaccination_centers_path
      end
    end

    def create_params
      params.require(:campaign).permit(
        :available_doses,
        :extra_info,
        :max_distance_in_meters,
        :min_age,
        :max_age,
        :starts_at,
        :ends_at,
        :vaccine_type
      )
    end

    def simulate_params
      params.require(:campaign).permit(:min_age, :max_age, :max_distance_in_meters, :vaccine_type, :available_doses)
    end

    def skip_pundit?
      # TODO add a real policy
      true
    end
  end
end
