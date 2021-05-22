module Partners
  class SessionsController < ::Devise::SessionsController
    before_action :define_as_page_pro
  end
end
