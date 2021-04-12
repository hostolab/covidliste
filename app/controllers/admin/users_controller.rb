module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[resend_confirmation]

    def index
      @user = User.find_by(email: params.dig(:user, :email)) || User.new(email: params.dig(:user, :email))
      @user_mails = MailProviderService.new.find_mails(@user.email).events if @user.persisted? && params.dig(:other, :with_mails)
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
      redirect_to admin_users_path unless @user
    end
  end
end
