class PartnersController < ApplicationController
  before_action :authenticate_partner!, except: %i[new create]
  helper_method :sort_column, :sort_direction
  invisible_captcha only: [:create], honeypot: :subtitle

  def new
    @partner = Partner.new
    skip_authorization
  end

  def create
    @partner = Partner.new(partner_params)
    authorize @partner
    @partner.statement_accepted_at if @partner.statement
    # @partner.password = Devise.friendly_token.first(12)
    # @partner.skip_confirmation! if ENV["SKIP_EMAIL_CONFIRMATION"] == 'true'
    @partner.save
    render action: :new
  end

  private

  def partner_params
    params.require(:partner).permit(:name, :email, :password, :phone_number, :statement)
  end

  def vaccination_center_params
    params.require(:vaccination_center).permit(:name, :description, :address, :kind, :pfizer, :moderna, :astrazeneca,
      :janssen, :phone_number, :lat, :lon)
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
