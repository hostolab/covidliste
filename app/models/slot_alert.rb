class SlotAlert < ApplicationRecord
  THROTTLING_RATE = 1
  THROTTLING_INTERVAL = 6.hours

  has_secure_token :token
  encrypts :token
  blind_index :token
  self.ignored_columns = ["token"]

  belongs_to :user
  belongs_to :vmd_slot

  validates :user_id, uniqueness: {scope: :vmd_slot_id}
  validate :throttling, on: :create
  after_create_commit :notify

  def throttling
    return unless user
    alerts_count = user.slot_alerts.where("created_at >= ?", THROTTLING_INTERVAL.ago).count
    errors.add(:base, "Too many alerts for this user") if alerts_count >= THROTTLING_RATE
  end

  def notify
    SendSlotAlertEmailJob.perform_later(id)
  end

  def follow_up
    SendSlotAlertFollowUpJob.perform_later(id)
  end
end
