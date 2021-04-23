Rails.application.configure do
  # Lograge config
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.colorize_logging = true
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"

  config.lograge.custom_options = lambda do |event|
    {
      ddsource: "ruby",
      time: Time.now,
      level: event.payload[:level],
      exception: event.payload[:exception],
      exception_object: event.payload[:exception_object]
    }
  end
end
