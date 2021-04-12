module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[resend_confirmation]

    def index
    end

    def search
      unless search_params[:email].blank?
        @user = User.find_by(email: search_params[:email])
        @user_mails = MailProviderService.new.find_mails(@user.email).events if @user && search_other_params[:with_mails]
      end
      render action: :index
    end

    def resend_confirmation
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
      @user = User.find(params[:id])
      redirect_to admin_user_path unless @user
    end

    def search_params
      params.fetch(:user, {}).permit(:email)
    end

    def search_other_params
      params.fetch(:other, {}).permit(:with_mails)
    end
  end
end
