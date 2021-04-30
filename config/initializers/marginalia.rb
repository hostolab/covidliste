module Marginalia
  module Comment
    def self.controller
      if marginalia_controller.respond_to?(:controller_path)
        marginalia_controller.controller_path
      end
    end
  end
end

Marginalia::Comment.components = %i[
  controller_with_namespace
  action
  line
  job
  sidekiq_job
]
