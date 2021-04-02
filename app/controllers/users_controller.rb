include ActionView::Helpers::NumberHelper
class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:new, :create]
  
  def new
    if current_user
      redirect_to profile_path
    else
      @user = User.new
      @users_count = number_with_delimiter(User.count, locale: :fr)
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
    @user.password = Devise.friendly_token.first(12)
    @user.skip_confirmation! if ENV["SKIP_EMAIL_CONFIRMATION"] == 'true'
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
    params.require(:user).permit(:firstname, :lastname, :email, :phone_number, :toc, :address, :birthdate, :lat, :lon)
  end

end
