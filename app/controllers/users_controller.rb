include ActionView::Helpers::NumberHelper
class UsersController < ApplicationController

  def new
    @user = User.new
    @users_count = number_with_delimiter(User.count, locale: :fr)
  end

  def create
    @user = User.new(user_params)
    if @user.address.empty?
      flash.now.alert = "Il faut compléter le champ adresse pour pouvoir vous inscrire."
    else
      result = Geocoder.search(@user.address)
      @user.latitude = result.first.data['lat'].to_f.round(2).to_s
      @user.longitude = result.first.data['lon'].to_f.round(2).to_s
      @user.address = nil
      @user.password = Devise.friendly_token.first(12)
      @user.skip_confirmation! if ENV["SKIP_EMAIL_CONFIRMATION"] == 'true'
      @user.save
    end
    render action: :new
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :phone_number, :toc, :address, :birthdate)
  end

  def geocode_address
  end
end
