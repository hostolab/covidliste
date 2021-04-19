class PagesController < ApplicationController
  def benevoles
  end

  def contact
    @contact_items = FaqItem.where(category: "Collaboration et contact")
  end

  def presse
  end

  def mentions_legales
  end

  def privacy
  end

  def algorithme
    @faq_item = FaqItem.find_by(title: "Comment fonctionne la sélection des volontaires ?")
  end

  def faq
    @faq_items = FaqItem.all
  end

  def robots
    render "pages/robots", layout: false, content_type: "text/plain"
  end

  StaticPage.all.each do |page|
    define_method page.slug.underscore do
      @body = page.body
      render "pages/static"
    end
  end

  private

  def skip_pundit?
    true
  end
end
