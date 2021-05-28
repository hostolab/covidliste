module Admin
  class PowerUsersController < BaseController
    before_action :power_user_params, only: [:create, :update, :destroy]

    def index
      @users = policy_scope([:power_users, User]).includes([:roles_users, :roles]).uniq
    end

    def create
      user = User.find_by(email: power_user_params[:email])
      if user&.present?
        authorize [:power_users, user]
        if Rails.application.config.x.covidliste["admin_roles"].key?(power_user_params[:role])
          flash[:error] = "Role non trouvé : #{power_user_params[:role]}"
          redirect_to admin_power_users_path
        end

        if (error = user.add_role power_user_params[:role])
          flash[:success] = "Role ajouté à #{user.email}"
        else
          flash[:error] = "Une erreur est survenue : #{error}"
        end
      else
        skip_authorization
        flash[:error] = "Utilisateur non trouvé : #{power_user_params[:email]}"
      end
      redirect_to admin_power_users_path
    end

    def update
      user = policy_scope([:power_users, User]).find(params[:id])
      if user&.present?
        authorize [:power_users, user]
        if (error = user.add_role power_user_params[:role])
          flash[:success] = "Role ajouté à #{user.email}"
        else
          flash[:error] = "Une erreur est survenue : #{error}"
        end
      else
        skip_authorization
        flash[:error] = "Utilisateur non trouvé : ##{params[:id]}"
        redirect_to admin_power_users_path
      end
      redirect_to admin_power_users_path
    end

    def destroy
      user = policy_scope([:power_users, User]).find(params[:id])
      if user&.present?
        authorize [:power_users, user]
        if (error = user.remove_role power_user_params[:role])
          flash[:success] = "Role retiré à #{user.email}"
        else
          flash[:error] = "Une erreur est survenue : #{error}"
        end
      else
        skip_authorization
        flash[:error] = "Utilisateur non trouvé : ##{params[:id]}"
        redirect_to admin_power_users_path
      end
      redirect_to admin_power_users_path
    end

    private

    def power_user_params
      params.require(:power_user).permit(:email, :role)
    end
  end
end
