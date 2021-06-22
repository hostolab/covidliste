module Timezone
  extend ActiveSupport::Concern

  MAPPING = {
    "971" => "America/Guadeloupe", # Guadeloupe
    "972" => "America/Martinique", #  Martinique
    "973" => "Georgetown", # Guyane
    "974" => "Indian/Reunion", # La Réunion
    "976" => "Indian/Mayotte" # Mayotte
  }

  included do
    before_validation :set_timezone, if: :geo_context?

    validates :timezone, presence: true
  end

  private

  def set_timezone
    self.timezone = (department_number && MAPPING[department_number]) || "Europe/Paris"
  end

  def department_number
    geo_context&.split(",")&.first
  end

  def department?
    department.present?
  end
end
