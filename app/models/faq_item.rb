class FaqItem < FrozenRecord::Base
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  add_index :title, unique: true

  def id
    @id ||= "collapse-#{title.parameterize}"
  end

  def body
    @body ||= begin
      body_md = ERB.new(body_md_erb).result(binding)
      Kramdown::Document.new(body_md).to_html.html_safe
    end
  end

  def self.search(search_term)
    if search_term
      FaqItem.all.select { |faq_item| faq_item.body_md_erb.include?(search_term) }
    else
      FaqItem.all
    end
  end

  private

  def controller
    @controller ||= begin
      controller = ApplicationController.new
      controller.define_singleton_method(:url_options) do
        Rails.application.config.action_mailer.default_url_options
      end
      controller
    end
  end
end
