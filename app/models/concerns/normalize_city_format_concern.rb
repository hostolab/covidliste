# frozen_string_literal: true

module NormalizeCityFormatConcern
  extend ActiveSupport::Concern

  included do
    before_validation :format_city_name
  end

  private

  def format_city_name
    return if city.blank?

    # Algolia returns "Paris 12e Arrondissement" so we have to remove this to normalize data
    [
      ["Paris", (1..20).to_a],
      ["Marseille", (1..8).to_a],
      ["Lyon", (1..9).to_a]
    ].each do |city, district_array|
      district_array.each do |district|
        s = district == 1 ? "#{city} #{district}er Arrondissement" : "#{city} #{district}e Arrondissement"

        self.city = self.city.gsub(s, city)
      end
    end
  end
end
