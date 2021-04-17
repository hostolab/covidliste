class UsersController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!, except: %i[new create]
  before_action :sign_out_if_anonymized!
  invisible_captcha only: [:create], honeypot: :subtitle
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def new
    skip_authorization
    if current_partner
      redirect_to partners_vaccination_centers_path
    elsif current_user
      redirect_to profile_path
    else
      @user = User.new(birthdate: Date.today.change(year: 1961))
      set_counters
    end
  end

  def show
    @user = current_user
    authorize @user
    prepare_phone_number
    respond_to do |format|
      format.html
      format.csv do
        send_data @user.to_csv, type: "text/csv", filename: "mes_donnees_covidliste.csv", disposition: :attachment
      end
    end
  end

  def update
    @user = current_user
    authorize @user
    if @user.update(user_params)
      flash.now[:success] = "Modifications enregistrées."
    else
      flash.now[:error] = "Impossible d'enregistrer vos modifications."
    end
    prepare_phone_number
    render action: :show
  end

  def create
    @user = User.new(user_params)
    authorize @user
    @user.save
    prepare_phone_number
    render action: :new
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Une erreur s’est produite."
    render action: :new
  end

  def delete
    @user = current_user
    authorize @user
    @user.destroy
    flash[:success] = "Votre compte a bien été supprimé."
    redirect_to root_path
  end

  private

  def set_counters
    @users_count = Rails.cache.fetch(:users_count, expires_in: 5.minute) do
      number_with_delimiter(User.count, locale: :fr).gsub(" ", "&nbsp;").html_safe
    end
    @matched_users_count = Rails.cache.fetch(:matched_users_count, expires_in: 5.minute) do
      number_with_delimiter(Match.distinct.count("user_id"), locale: :fr).gsub(" ", "&nbsp;").html_safe
    end
    @confirmed_matched_users_count = Rails.cache.fetch(:confirmed_matched_users_count, expires_in: 5.minute) do
      number_with_delimiter(Match.confirmed.count, locale: :fr).gsub(" ", "&nbsp;").html_safe
    end
    @vaccination_centers_count = Rails.cache.fetch(:vaccination_centers_count, expires_in: 5.minute) do
      number_with_delimiter(VaccinationCenter.confirmed.count, locale: :fr).gsub(" ", "&nbsp;").html_safe
    end
  end

  def prepare_phone_number
    @user.phone_number = @user.human_friendly_phone_number
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :phone_number, :toc, :address, :birthdate, :password, :statement)
  end

  def sign_out_if_anonymized!
    if current_user&.anonymized_at
      flash[:notice] = "Votre compte a été anonymisé car vous avez confirmé un RDV avec un centre de vaccination"
      sign_out
      redirect_to root_path
    end
  end

  def user_not_authorized(exception)
    policy_name = exception
      .policy.class.to_s.underscore
    message = exception.message || (t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default)
    flash[:error] = message
    redirect_to(request.referrer || root_path)
  end
end
