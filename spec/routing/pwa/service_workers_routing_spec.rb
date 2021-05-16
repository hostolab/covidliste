require "rails_helper"

describe Pwa::ServiceWorkersController, type: :routing do
  it {
    expect(get: "/service_worker.js")
      .to route_to(
        controller: "pwa/service_workers",
        action: "show",
        format: "js"
      )
  }
end
