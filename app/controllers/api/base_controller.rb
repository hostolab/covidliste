module Api
  class BaseController < ApplicationController
    API_TOKEN = ENV["COVIDLISTE_API_TOKEN"]
    before_action :authenticate!
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def authenticate!
      if API_TOKEN.blank?
        return user_not_authorized
      end
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, API_TOKEN)
      end
    end

    def user_not_authorized
      render json: {error: {message: "Access denied"}}, status: :forbidden
    end

    # Redefine pundit specific methods to handle :api namespace properly.
    def policy_scope(scope)
      # Flatten the scope to handle sub namespace (e.g. [:power_users, User]).
      super([:api, scope].flatten)
    end

    def authorize(record, query = nil)
      super([:api, record], query)
    end
  end
end
