require "ddtrace"

unless Rails.env.test?
  Datadog.configure do |c|
    c.use :rails, service_name: "covidliste"
  end
end
