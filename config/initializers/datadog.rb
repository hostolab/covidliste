Datadog.configure do |c|
  c.use :rails, service_name: "covidliste"
  c.tracer.transport_options = proc { |t|
    t.adapter :net_http,
              Datadog::Transport::HTTP.default_hostname,
              Datadog::Transport::HTTP.default_port,
              { timeout: 30 }
  }
end
