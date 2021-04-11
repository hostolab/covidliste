class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery prepend: true

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  unless Rails.env.development?
    content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src :self, :data, :https
      policy.img_src :self, :data, :https
      policy.object_src :none
      policy.script_src :strict_dynamic
      policy.style_src :self, :https, :unsafe_inline
    end
  end

  def skip_pundit?
    devise_controller?
  end
end
