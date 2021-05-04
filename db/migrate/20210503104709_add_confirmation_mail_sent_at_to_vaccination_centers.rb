class AddConfirmationMailSentAtToVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :confirmation_mail_sent_at, :datetime
  end
end
