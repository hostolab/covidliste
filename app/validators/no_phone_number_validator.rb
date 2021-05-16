class NoPhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if Phonelib.parse(value).valid?
      record.errors.add(attribute, "ne doit pas contenir de numéro de téléphone")
    end
  end
end
