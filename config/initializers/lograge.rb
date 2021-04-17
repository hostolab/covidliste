require "lograge/sql/extension"

Rails.application.configure do
  # Lograge config
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.colorize_logging = true

  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params],
      ddsource: ["ruby"],
      level: event.payload[:level],
      exception: event.payload[:exception],
      exception_object: event.payload[:exception_object]
    }
  end
end
