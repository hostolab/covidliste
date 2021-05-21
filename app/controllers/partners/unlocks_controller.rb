module Partners
  class UnlockssController < ::Devise::UnlockssController
    before_action :define_as_page_pro
  end
end
