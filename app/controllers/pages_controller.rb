class PagesController < ApplicationController
  def mentions_legales
  end

  def privacy
  end

  def faq
  end

  def robots
    render "pages/robots", layout: false, content_type: "text/plain"
  end
end
