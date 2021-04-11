# frozen_string_literal: true

module HasPhoneNumberConcern
  extend ActiveSupport::Concern

  included do
    before_validation :format_phone_number
    validates :phone_number, length: {minimum: 7, maximum: 15, allow_blank: false}
  end

  def human_friendly_phone_number
    phone_number.gsub(/^33/, "0").match(/(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/).captures
      .join(" ")
  end

  private

  def format_phone_number
    return if phone_number.blank?

    new_phone = phone_number.to_s

    # Remove separators and other unicode characters
    # 06  12-23.4.5 67-8
    # => 0612345678
    patterns = [" ", "+", "-", ".", ",", "/", "－", "–", "_", "\u00A0", "\u202C", "\u202D", "\u0020", "~", "—", "@",
      "*", "	", "\t"]
    patterns.each do |string|
      new_phone = new_phone.gsub(string, "")
    end

    # Remove two leading zeros
    # 00336xx
    # => 336xx
    new_phone = new_phone[2..] if new_phone.length > 2 && new_phone[0..1] == "00"

    # French mobile and fix numbers have 10 digits, and we want a 33x number
    # 0612345678
    # => 33612345678
    if new_phone.length == 10 && new_phone[0..0] == "0"
      # "FR 06 xx xx xx xx"
      # "FR 07 xx xx xx xx"
      # "FR 01 xx xx xx xx"
      new_phone = "33" + new_phone[1..]
    end

    self.phone_number = new_phone
  end
end
