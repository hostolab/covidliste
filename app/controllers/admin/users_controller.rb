module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show resend_confirmation]
    before_action :search_params, only: [:index]
    before_action :search_other_params, only: [:index]

    def index
      @user_search = User.new
    end

    def search
      @user_search = User.new
      unless search_params[:email].blank?
        @user_search.email = search_params[:email]
        @user = User.find_by(email: search_params[:email])
        if @user && search_other_params[:with_mails]
          @user_mails = MailProviderService.new.find_mails(@user.email).events
        end
      end
      render action: :index
    end

    def show
      @user_search = User.new
      @user_search.email = @user.email
      render action: :index
    end

    def resend_confirmation
      @user_search = User.new
      @user_search.email = @user.email
      if @user.confirmed?
        flash[:alert] = "Cet utilsateur a déjà été validé !"
      elsif @user.send_confirmation_instructions
        flash[:success] = "Le mail de confirmation a été renvoyé"
      else
        flash[:alert] = "Une erreur est survenue : #{@user.errors.full_messages.join(", ")}"
      end
      render action: :index
    end

    private

    def set_user
      if params[:id]
        @user = User.find(params[:id])
      else
        redirect_to admin_user_path
      end
    end

    def search_params
      params.fetch(:user, {}).permit(:email)
    end

    def search_other_params
      params.fetch(:other, {}).permit(:with_mails)
    end
  end
end
