class Campaign < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :partner

  has_many :campaign_batches
  has_many :matches

  enum status: {running: 0, completed: 1, canceled: 2}

  validates :available_doses, numericality: {greater_than: 0}
  validates :vaccine_type, presence: true
  validates :min_age, numericality: {greater_than: 17}
  validates :max_age, numericality: {greater_than: 17}
  validates :max_distance_in_meters, numericality: {greater_than: 0}
  validate :min_age_lesser_than_max_age
  validate :starts_at_lesser_than_ends_at

  def remaining_slots
    available_doses - matches.confirmed.size
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[firstname lastname birthdate phone_number confirmed_at]
      matches.confirmed.order(:confirmed_at).each do |match|
        csv << [
          match.user.firstname,
          match.user.lastname,
          match.user.birthdate,
          match.user.phone_number,
          match.confirmed_at
        ]
      end
    end
  end

  private

  def min_age_lesser_than_max_age
    if (min_age || 0) >= (max_age || 0)
      errors.add(:max_age, "doit être supérieur à l’âge minimum")
    end
  end

  def starts_at_lesser_than_ends_at
    if starts_at >= ends_at
      errors.add(:ends_at, "doit être postérieur à la date de début")
    end
  end
end
