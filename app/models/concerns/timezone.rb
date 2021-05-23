module Timezone
  extend ActiveSupport::Concern

  MAPPING = {
    "GY" => "Guyane",
    "GP" => "Guadeloupe",
    "RE" => "La Réunion",
    "MQ" => "Martinique",
    "YT" => "Mayotte"
  }

  included do
    attr_accessor :department

    before_validation :set_timezone, if: :department?

    validates :timezone, presence: true
  end

  private

  def set_timezone
    self.timezone = ActiveSupport::TimeZone.send(
      :load_country_zones, department_code
    ).first.name
  end

  def department_code
    MAPPING.key(department) || "FR"
  end

  def department?
    department.present?
  end
end
