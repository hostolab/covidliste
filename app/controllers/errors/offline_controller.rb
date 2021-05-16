# frozen_string_literal: true

module Errors
  class OfflineController < ApplicationController
    def show
    end

    private

    def skip_pundit?
      true
    end
  end
end
