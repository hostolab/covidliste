include ActionView::Helpers::NumberHelper
class UsersController < ApplicationController
  
  def new
    @user = User.new
    @users_count = number_with_delimiter(User.count, locale: :fr)
  end

  def create
    @user = User.new(user_params)
    @user.password = Devise.friendly_token.first(12)
    @user.skip_confirmation! if ENV["SKIP_EMAIL_CONFIRMATION"] == 'true'
    @user.save
    render action: :new
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :phone_number, :toc, :address, :birthdate)
  end

end
