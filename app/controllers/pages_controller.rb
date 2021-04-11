class PagesController < ApplicationController
  def mentions_legales
  end

  def privacy
  end

  def faq
    @faq_items = FaqItem.all
  end

  def robots
    render "pages/robots", layout: false, content_type: "text/plain"
  end

  private

  def skip_pundit?
    true
  end
end
