class ModalComponentPreview < ViewComponent::Preview
  def with_default_title
    render(ModalComponent.new(title: "Modal component default title"))
  end

  def with_content_block
    render(ModalComponent.new(title: "This component accepts a block of content")) do
      "Hello"
    end
  end
end
