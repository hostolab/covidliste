module Timezone
  extend ActiveSupport::Concern

  MAPPING = {
    "Guyane" => "Georgetown",
    "Guadeloupe" => "America/Guadeloupe",
    "La Réunion" => "Indian/Reunion",
    "Martinique" => "America/Martinique",
    "Mayotte" => "Indian/Mayotte"
  }

  included do
    attr_accessor :department

    before_validation :set_timezone, if: :department?

    validates :timezone, presence: true
  end

  private

  def set_timezone
    self.timezone = MAPPING[department] || "Europe/Paris"
  end

  def department?
    department.present?
  end
end
