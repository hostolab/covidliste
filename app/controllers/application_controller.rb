class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery prepend: true

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  unless Rails.env.development?
    content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src :self, :data, :https
      policy.img_src :self, :data, :https, :blob
      policy.object_src :none
      policy.script_src :strict_dynamic, :self
      policy.style_src :self, :https, :unsafe_inline
      policy.worker_src :blob
      policy.child_src :blob
    end
  end

  def skip_pundit?
    devise_controller?
  end

  def append_info_to_payload(payload)
    super
    payload[:level] = if payload[:status] == 200
      "INFO"
    elsif payload[:status] == 302
      "WARN"
    else
      "ERROR"
    end
  end
end
