require "rails_helper"

RSpec.describe ModalComponent, type: :component do
  it "renders component" do
    with_controller_class PagesController do
      render_inline(described_class.new(title: "my title")) { "Hello, World!" }
    end
  end
end
