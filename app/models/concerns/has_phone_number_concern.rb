# frozen_string_literal: true

module HasPhoneNumberConcern
  extend ActiveSupport::Concern

  included do
    before_validation :format_phone_number, if: :phone_number?
    validates :phone_number,
      phone: {
        possible: true,
        types: %i[mobile voip],
        allow_blank: false
      }
  end

  def human_friendly_phone_number
    Phonelib.parse(phone_number).national
  end

  private

  def format_phone_number
    self.phone_number = Phonelib.parse(phone_number).full_e164
  end
end
