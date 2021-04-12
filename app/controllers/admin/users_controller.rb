class Admin::UsersController < Admin::BaseController
  def index
    users = policy_scope([:admin, User.all])
    @user = users.find_by(email: params.dig(:user, :email)) || User.new(email: params.dig(:user, :email))
  end

  def destroy
    @user = User.find(params[:id])
    authorize [:admin, @user]
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: "l'utilisateur a été supprimé." }
    end
  end
end
