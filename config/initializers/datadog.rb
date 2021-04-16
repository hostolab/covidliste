Datadog.configure do |c|
  c.tracer enabled: Rails.env.production?
  c.use :rails, service_name: "covidliste"
end
