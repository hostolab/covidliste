module SortHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == :desc ? :asc : :desc
    params_to_merge = params.to_unsafe_h.reject { |k, _| k.in? ["action", "controller", "utf8", "sort", "direction"] }
    link_to title, {sort: column, direction: direction}.merge(params_to_merge), {class: css_class}
  end
end
