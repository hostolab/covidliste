class StaticPage < FrozenRecord::Base
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  include ActiveModel::Validations
  validates :body_md_erb, :slug, presence: true

  add_index :slug, unique: true

  def body
    @body ||= begin
      body_md = ERB.new(body_md_erb).result(binding)
      Kramdown::Document.new(body_md).to_html.html_safe
    end
  end
end
