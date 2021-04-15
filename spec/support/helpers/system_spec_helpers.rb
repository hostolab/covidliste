module SystemSpecHelpers
  def accept_confirm_modal
    yield if block_given?
    find("[data-behavior='commit']").click
  end

  def decline_confirm_modal
    yield if block_given?
    find("[data-behavior='cancel']").click
  end
end
