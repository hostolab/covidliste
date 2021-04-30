module Admin
  class CampaignsController < BaseController
    before_action :search_params, only: [:index]
    before_action :set_filters, only: [:index]

    helper_method :sort_column, :sort_direction

    def index
      campaigns = policy_scope(Campaign)

      # Filters
      campaigns = campaigns.where(status: @statuses) if @statuses.present?
      campaigns = campaigns.where(vaccine_type: @vaccines) if @vaccines.present?

      respond_to do |format|
        format.html {
          @pagy_campaigns, @campaigns = pagy(campaigns.includes(:vaccination_center).order(ActiveRecord::Base.sanitize_sql("#{sort_column} #{sort_direction}")))
        }
      end
    end

    private

    def sort_column
      Campaign.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction].to_sym : :desc
    end

    def search_params
      params.permit(
        statuses: [],
        vaccines: []
      )
    end

    def set_filters
      @statuses = search_params[:statuses].to_a.reject(&:blank?)
      @vaccines = search_params[:vaccines].to_a.reject(&:blank?)
    end
  end
end
