module Partners
  class UnlocksController < ::Devise::UnlocksController
    before_action :define_as_page_pro
  end
end
