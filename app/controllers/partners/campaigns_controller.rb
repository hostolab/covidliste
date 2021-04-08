module Partners
  class CampaignsController < ApplicationController
    before_action :authenticate_partner!
    before_action :find_vaccination_center, except: :show
    before_action :find_campaign, only: :show
    before_action :authorize!

    def show
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
        redirect_to partners_campaign_path(@campaign)
      else
        render :new
      end
    end

    def simulate_reach
      # TODO: we should validate params here before running simulation
      reach = @vaccination_center.reachable_users_query(
        min_age: params[:min_age],
        max_age: params[:max_age],
        max_distance_in_meters: params[:max_distance_in_meters].to_i
      ).count
      render json: {reach: reach}
    end

    private

    def authorize!
      return if @vaccination_center.can_be_accessed_by?(nil, current_partner)

      flash[:error] = "Vous ne pouvez pas accéder à ce centre de vaccination"
      redirect_to partners_vaccination_centers_path
    end

    def find_campaign
      @campaign = Campaign.find(params[:id])
      @vaccination_center = @campaign.vaccination_center
    end

    def find_vaccination_center
      @vaccination_center = VaccinationCenter.find(params[:vaccination_center_id])

      if @vaccination_center.confirmed_at.nil?
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
  end
end
