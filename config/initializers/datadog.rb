Datadog.configure do |c|
  c.tracer enabled: false
  c.use :rails, service_name: "covidliste"
end
