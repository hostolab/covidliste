class SlotAlert < ApplicationRecord
  has_secure_token :token
  encrypts :token
  blind_index :token

  belongs_to :user
  belongs_to :vmd_slot

  after_create_commit :send_email

  def send_email
    SendSlotAlertEmailJob.perform_later(id)
  end
end
