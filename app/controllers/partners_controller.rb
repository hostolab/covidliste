class PartnersController < ApplicationController
  before_action :authenticate_partner!, except: %i[new create]
  helper_method :sort_column, :sort_direction

  def new
    @partner = Partner.new
  end

  def show
    @partner = current_partner
    prepare_phone_number
  end

  def update
    @partner = current_partner
    if @partner.update(partner_params)
      flash.now[:success] = "Modifications enregistrées."
    else
      flash.now[:error] = "Impossible d'enregistrer vos modifications."
    end
    prepare_phone_number
    render action: :show
  end

  def create
    @partner = Partner.new(partner_params)
    # @partner.password = Devise.friendly_token.first(12)
    # @partner.skip_confirmation! if ENV["SKIP_EMAIL_CONFIRMATION"] == 'true'
    @partner.save
    prepare_phone_number
    render action: :new
  end

  def delete
    @partner = current_partner
    @partner.destroy
    flash[:success] = "Votre compte a bien été supprimé."
    redirect_to root_path
  end

  private

  def prepare_phone_number
    @partner.phone_number = @partner.human_friendly_phone_number_or_fallback
  end

  def partner_params
    params.require(:partner).permit(:name, :email, :password, :phone_number)
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

  def skip_pundit?
    # TODO add a real policy
    true
  end
end
