module Admin
  class HomeController < Admin::BaseController

    def index
      @user = current_user
    end

  end
end
