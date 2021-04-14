# frozen_string_literal: true

module HasPhoneNumberConcern
  extend ActiveSupport::Concern

  included do
    before_validation :format_phone_number, if: :phone_number?
    validates :phone_number, phone: {
      types: %i[mobile],
      allow_blank: false
    }
  end

  def human_friendly_phone_number
    if parsed_phone_number.valid_for_country?(:fr)
      parsed_phone_number.national
    else
      parsed_phone_number.e164
    end
  end

  private

  def parsed_phone_number
    @parsed_phone_number ||= Phonelib.parse(phone_number)
  end

  def format_phone_number
    self.phone_number = Phonelib.parse(phone_number).full_e164
  end
end
