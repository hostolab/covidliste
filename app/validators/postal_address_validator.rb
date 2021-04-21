class PostalAddressValidator < ActiveModel::EachValidator
  REGEX_ZIPCODE = %r{
    \d{2}[ ]?\d{3}  # France
    |
    973\d{2}        # Guyane
    |
    9[78][01]\d{2}  # Guadeloupe
    |
    9[78]4\d{2}     # La Réunion
    |
    9[78]2\d{2}     # Martinique
    |
    976\d{2}        # Mayotte
  }x

  def initialize(options)
    @with_zipcode = !options[:with_zipcode].nil? ? options[:with_zipcode] : true
    super
  end

  def validate_each(record, attribute, value)
    unless @with_zipcode.nil? || value.match?(REGEX_ZIPCODE)
      record.errors.add(attribute, (options[:message] || I18n.t("errors.messages.missing_zipcode")))
    end
  end
end
