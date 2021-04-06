include ActionView::Helpers::NumberHelper
class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:new, :create]

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
  end

  def update
    @user = current_user
    @user.update(user_params)
    flash.now[:success] = "Modifications enregistrées"
    render action: :show
  end

  def create
    @user = User.new(user_params)
    @user.save
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
    params.require(:user).permit(:firstname, :lastname, :email, :phone_number, :toc, :address, :birthdate, :lat, :lon, :password)
  end

end
