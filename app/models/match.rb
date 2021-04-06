class Match < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :campaign
  belongs_to :campaign_batch
  belongs_to :user

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    !confirmed_at.nil?
  end

  def confirm!
    update(confirmed_at: Time.now.utc) unless confirmed?
  end

  def expired?
    !confirmed? && Time.now.utc > expires_at
  end

end
