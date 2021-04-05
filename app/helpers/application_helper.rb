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

  def sortable(column, title = nil, reverse_display = false)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    column == sort_column && title += if reverse_display
                                        sort_direction == "asc" ? " ↓" : " ↑"
                                      else
                                        sort_direction == "asc" ? " ↑" : " ↓"
                                      end
    link_to title, request.parameters.merge({sort: column, direction: direction}), { class: css_class }
  end
end
