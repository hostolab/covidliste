module ApplicationHelper

  def message_flash(key, value)
    type = {
      'success': 'success',
      'error': 'danger',
      'alert': 'warning',
      'notice': 'primary',
    }[key.to_sym]
    content_tag(
      'div',
      nil,
      class: "alert alert-#{type}",
      role: 'alert',
      style: 'position: inherit'
    ) do
      concat(value)
    end
  end

end
