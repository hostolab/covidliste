# frozen_string_literal: true

module Pwa
  class ManifestsController < ApplicationController
    layout false

    before_action :set_icons

    ICON_SIZES = [48, 72, 96, 128, 192, 384, 512].freeze
    BACKGROUND_COLOR = "#fff"
    THEME_COLOR = "#2c1b2d"

    def show
      render json: {short_name: Rails.application.class.module_parent.name,
                    name: Rails.application.class.module_parent.name,
                    icons: @icons,
                    start_url: root_path(source: "pwa"),
                    background_color: BACKGROUND_COLOR,
                    display: "standalone",
                    scope: root_path,
                    theme_color: THEME_COLOR,
                    description: Rails.application.class.module_parent.name,
                    screenshots: screenshots}
    end

    private

    def screenshots
      [
        {
          src: "/pwa/screenshot.png",
          type: Mime[:png].to_s,
          sizes: "1920x1326"
        }
      ]
    end

    def set_icons
      @icons = ICON_SIZES.map do |size|
        {
          src: "/pwa/maskable_icon_x#{size}.png",
          type: Mime[:png].to_s,
          sizes: "#{size}x#{size}",
          purpose: "any maskable"
        }
      end
    end

    def skip_pundit?
      true
    end
  end
end
