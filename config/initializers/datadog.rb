unless Rails.env.test?
  require "ddtrace"

  Datadog.configure do |c|
    c.use :rack, quantize: { query: { show: :all } }
    c.use :rails, log_injection: true
  end
end
