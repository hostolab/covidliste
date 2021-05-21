class SlotAlert < ApplicationRecord
  has_secure_token :token
  encrypts :token
  blind_index :token
  self.ignored_columns = ["token"]

  belongs_to :user
  belongs_to :vmd_slot

  validates :user_id, uniqueness: {scope: :vmd_slot_id}

  after_create_commit :send_email

  def send_email
    SendSlotAlertEmailJob.perform_later(id)
  end
end
