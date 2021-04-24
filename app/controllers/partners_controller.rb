class PartnersController < ApplicationController
  before_action :authenticate_partner!, except: %i[new create]
  helper_method :sort_column, :sort_direction
  invisible_captcha only: [:create], honeypot: :subtitle
  rescue_from Pundit::NotAuthorizedError, with: :partner_not_authorized

  def new
    skip_authorization
    if current_partner
      redirect_to partners_vaccination_centers_path
    elsif current_user
      redirect_to profile_path
    else
      @partner = Partner.new
    end
  end

  def show
    @partner = current_partner
    authorize @partner
    prepare_phone_number
    respond_to do |format|
      format.html
      format.csv do
        send_data @partner.to_csv, type: "text/csv", filename: "mes_donnees_covidliste.csv", disposition: :attachment
      end
    end
  end

  def update
    @partner = current_partner
    authorize @partner
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
    authorize @partner
    @partner.statement_accepted_at = Time.zone.now if @partner.statement
    @partner.visible_optin_at = Time.zone.now if @partner.visible_optin
    @partner.media_optin_at = Time.zone.now if @partner.media_optin
    # @partner.password = Devise.friendly_token.first(12)
    # @partner.skip_confirmation! if ENV["SKIP_EMAIL_CONFIRMATION"] == 'true'
    @partner.save
    prepare_phone_number
    render action: :new
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Une erreur s’est produite."
    render action: :new
  end

  def destroy
    @partner = current_partner
    authorize @partner
    @partner.destroy
    flash[:success] = "Votre compte a bien été supprimé."
    redirect_to root_path
  end

  private

  def partner_params
    params.require(:partner).permit(:name, :email, :password, :phone_number, :statement, :visible_optin, :media_optin)
  end

  def prepare_phone_number
    @partner.phone_number = @partner.human_friendly_phone_number
  end

  def pundit_user
    current_partner
  end

  def partner_not_authorized(exception)
    policy_name = exception
      .policy.class.to_s.underscore
    message = exception.message || (t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default)
    flash[:error] = message
    redirect_to(request.referrer || root_path)
  end
end
