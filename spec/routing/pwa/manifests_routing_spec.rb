require "rails_helper"

describe Pwa::ManifestsController, type: :routing do
  it {
    expect(get: '/manifest.webmanifest')
      .to route_to(
        controller: 'pwa/manifests',
        action: 'show',
        format: 'webmanifest'
      )
  }
end
