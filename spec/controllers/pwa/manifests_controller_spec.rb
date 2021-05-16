require "rails_helper"

describe Pwa::ManifestsController, type: :controller do
  let(:manifest) do
    File.read(Rails.root.join(__dir__, "manifest.webmanifest"))
  end

  describe "#show" do
    before { get :show, format: :webmanifest }

    it { expect(response).to have_http_status :ok }
    it { expect(JSON.parse(response.body)).to eq JSON.parse(manifest) }
  end
end
