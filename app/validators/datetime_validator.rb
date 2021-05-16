class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !datetime?(value)
      errors.add(attribute, :invalid)
    elsif earlier_than_value && value > earlier_than_value
      errors.add(attribute, :too_late, value: earlier_than_value)
    elsif later_than_value && value < later_than_value
      errors.add(attribute, :too_soon, value: later_than_value)
    end
  end

  private

  def earlier_than_value
    if options[:earlier_than].respond_to?(:call)
      options[:earlier_than].call
    else
      options[:earlier_than].call
    end
  end

  def later_than_value
    if options[:later_than].respond_to?(:call)
      options[:later_than].call
    else
      options[:later_than].call
    end
  end

  def datetime?(value)
    value.is_a?(Time) || value.is_a?(DateTime)
  end
end
