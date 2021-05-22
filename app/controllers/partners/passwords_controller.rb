module Partners
  class PasswordsController < ::Devise::PasswordsController
    before_action :define_as_page_pro
  end
end
