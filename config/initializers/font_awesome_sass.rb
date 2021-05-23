# We removed font-awesome-sass gem dependency, but i wanted to keep the method 'icon'
# (Source: https://github.com/FortAwesome/font-awesome-sass/blob/master/lib/font_awesome/sass/rails/helpers.rb)
ActiveSupport.on_load(:action_view) do
  ActionView::Helpers.class_eval do
    def icon(style, name, text = nil, html_options = {})
      text, html_options = nil, text if text.is_a?(Hash)

      html_options[:class] = "#{style} fa-#{name}#{" #{html_options[:class]}" if html_options.key?(:class)}"
      html_options["aria-hidden"] ||= true

      html = content_tag(:i, nil, html_options)
      html << " #{text}" if text.present?
      html
    end
  end
end
