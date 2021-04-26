class PagesController < ApplicationController
  def benevoles
    @volunteers = Volunteer.where(anon: false).order(sort_name: :asc) + Volunteer.where(anon: true).order(sort_name: :asc)
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
    respond_to do |format|
      format.html do
        @faq_items = Rails.cache.fetch("faq_items", expires_in: 2.hours) { FaqItem.all }
      end
      format.json do
        render json: Rails.cache.fetch("faq_items_json", expires_in: 2.hours) { FaqItem.all.to_json }
      end
    end
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
