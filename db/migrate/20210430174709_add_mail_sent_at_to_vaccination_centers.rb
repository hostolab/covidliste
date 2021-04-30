class AddMailSentAtToVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :mail_sent_at, :datetime
  end
end
