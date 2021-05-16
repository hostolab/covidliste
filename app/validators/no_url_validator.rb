require "uri"

class NoUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.to_s.match?(URI::DEFAULT_PARSER.make_regexp)
      record.errors.add(attribute, "ne doit pas contenir d'URL")
    end
  end
end
