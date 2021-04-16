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
      @campaign = @vaccination_center.campaigns.build(ends_at: 1.hour.from_now)
    end

    def create
      @campaign = @vaccination_center.campaigns.build(create_params)
      @campaign.partner = current_partner
      @campaign.max_distance_in_meters = create_params["max_distance_in_meters"].to_i * 1000

      if @campaign.save
        @campaign.update(name: "Campagne ##{@campaign.id} du #{@campaign.created_at.strftime("%d/%m/%Y")}")
        SendCampaignJob.perform_later(@campaign, current_partner)
        PushNewCampaignToSlackJob.perform_later(@campaign)
        redirect_to partners_campaign_path(@campaign)
      else
        @campaign.max_distance_in_meters = @campaign.max_distance_in_meters / 1000
        render :new
      end
    end

    def update
      if params[:cancel] == "true" && @campaign.running?
        @campaign.canceled!
        flash[:notice] = "La campagne a bien été annulée. Attention, des volontaires ont reçu des SMS et peuvent encore confirmer dans les prochaines #{SendCampaignJob::BATCH_EXPIRE_IN_MINUTES} minutes"
        redirect_to partners_campaign_path(@campaign)
      end
    end

    def simulate_reach
      # TODO: we should validate params here before running simulation
      payload = simulate_params.to_h.symbolize_keys
      vaccine_type = payload.delete(:vaccine_type)
      available_doses = payload.delete(:available_doses)

      reach = @vaccination_center.reachable_users_query(**payload).count
      render json: {
        reach: Rails.env.production? ? reach : 1,
        enough: reach >= (Vaccine.minimum_reach_to_dose_ratio(vaccine_type) * available_doses)
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
