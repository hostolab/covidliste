module Partners
  class CampaignsController < ApplicationController
    before_action :authenticate_partner!
    before_action :load_vaccination_center

    def show
      unless @vaccination_center.campaigns.exists?(params[:id])
        redirect_to partners_vaccination_center_path(@vaccination_center.id) and return
      end
      @campaign = @vaccination_center.campaigns.find(params[:id])
    end

    def new
      if @vaccination_center
        @campaign = Campaign.new
      else
        redirect_to partners_path and return
      end
    end

    def create
      campaign = @vaccination_center.campaigns.create!(
        create_params.merge(
          'partner_id'             => current_partner.id,
          'max_distance_in_meters' => create_params['max_distance_in_meters'].to_i * 1000
        )
      )
      campaign.update(name: "campagne ##{campaign.id} du #{campaign.created_at.strftime('%d/%m/%Y')}")
      redirect_to partners_vaccination_center_campaign_path(vaccination_center_id: @vaccination_center.id, id: campaign.id)
    end

    private

    def load_vaccination_center
      @vaccination_center =
        PartnerVaccinationCenter
          .find_by(id: params[:vaccination_center_id], partner_id: current_partner.id)
          &.vaccination_center
    end

    def create_params
      params.require(:campaign).permit(
        :available_doses,
        :ends_at,
        :extra_info,
        :max_distance_in_meters,
        :min_age,
        :max_age,
        :starts_at,
        :vaccine_type
      )
    end
  end
end
