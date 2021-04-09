class UsersController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!, except: %i[new create]

  def new
    if current_partner
      redirect_to partners_vaccination_centers_path
    elsif current_user
      redirect_to profile_path
    else
      @user = User.new
      @users_count = Rails.cache.fetch(:users_count, expires_in: 1.minute) do
        number_with_delimiter(User.count, locale: :fr).gsub(" ", "&nbsp;").html_safe
      end
    end
  end

  def show
    @user = current_user
    respond_to do |format|
      format.html
      format.csv do
        send_data @user.to_csv, type: "text/csv", filename: "mes_donnees_covidliste.csv", disposition: :attachment
      end
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash.now[:success] = "Modifications enregistrées."
    else
      flash.now[:error] = "Impossible d'enregistrer vos modifications."
    end
  end

  def create
    @user = User.new(user_params)

    if !@user.save
      flash.now[:error] = "Impossible de créer un compte : #{@user.errors.full_messages.join(", ")}"
    end

    render action: :new
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Une erreur s’est produite."
    render action: :new
  end

  def delete
    @user = current_user
    @user.destroy
    flash[:success] = "Votre compte a bien été supprimé."
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :phone_number, :toc, :address, :birthdate, :lat,
      :lon, :zipcode, :city, :password, :statement)
  end
end
