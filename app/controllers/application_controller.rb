class ApplicationController < ActionController::Base
  if !Rails.env.development?
    content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src    :self, :data, :https
      policy.img_src     :self, :data, :https
      policy.object_src  :none
      policy.script_src  :strict_dynamic
      policy.style_src   :self, :https, :unsafe_inline
    end
  end
end
