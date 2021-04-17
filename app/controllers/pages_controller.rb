class PagesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def home
    @users_count = Rails.cache.fetch(:users_count, expires_in: 5.minute) do
      number_with_delimiter(User.count, locale: :fr).gsub(" ", "&nbsp;").html_safe
    end
  end

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

  private

  def skip_pundit?
    true
  end
end
