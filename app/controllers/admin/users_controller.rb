module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[resend_confirmation destroy]

    def index
      @user = policy_scope(User).find_or_initialize_by(email: params.dig(:user, :email))
      return unless @user.persisted? && params.dig(:other, :with_mails)

      @user_mails = MailProviderService.new.find_mails(@user.email).events
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

    def destroy
      @user.anonymize!

      respond_to do |format|
        format.html { redirect_to admin_users_url, notice: "l'utilisateur a été supprimé." }
      end
    end

    private

    def set_user
      # TODO: go for @user = authorize(User.find(params[:id])) when
      # https://github.com/varvet/pundit/issues/666 is fixed.
      @user = User.find(params[:id])
      authorize(@user)

      redirect_to(admin_users_path) unless @user
    end
  end
end
