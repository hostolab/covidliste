class PagesController < ApplicationController
  before_action :set_counters, only: [:home]

  def home
    @user = User.new(birthdate: Date.today.change(year: 1961))
  end

  def benevoles
    @volunteers = Volunteer.where(anon: false).order(sort_name: :asc) + Volunteer.where(anon: true).order(sort_name: :asc)
  end

  def donateurs
    ulule_project_slug = "covidliste"
    service = UluleService.new(ulule_project_slug)
    @project = service.project
    @bronze_supporters = service.get_supporters(150, 500)
    @silver_supporters = service.get_supporters(500, 100)
    @gold_supporters = service.get_supporters(1000, 5000)
    @diamond_supporters = service.get_supporters(5000, 99999999)
  end

  def contact
    @contact_items = FaqItem.where(category: "Collaboration et contact")
  end

  def presse
  end

  def carte
    @vaccination_centers = VaccinationCenter.confirmed.map do |v|
      if v.approximated_lon.present? && v.approximated_lat.present?
        {
          "name" => "Lieu de vaccination inscrit",
          "description" => "La localisation est approximée à quelques kilomètres",
          "lon" => v.approximated_lon,
          "lat" => v.approximated_lat
        }
      end
    end

    @map_areas = [
      {
        "label" => "France métropolitaine",
        "lon" => 2.3,
        "lat" => 47.1,
        "zoom" => 5.5
      },
      {
        "label" => "Guyane",
        "lon" => -53.02730090442361,
        "lat" => 4,
        "zoom" => 7
      },
      {
        "label" => "Guadeloupe",
        "lon" => -61.5,
        "lat" => 16.176021024448076,
        "zoom" => 10
      },
      {
        "label" => "La Réunion",
        "lon" => 55.53913649067738,
        "lat" => -21.153674695744286,
        "zoom" => 10
      },
      {
        "label" => "Martinique",
        "lon" => -60.97336870145841,
        "lat" => 14.632175285699219,
        "zoom" => 10
      },
      {
        "label" => "Mayotte",
        "lon" => 45.16242028163609,
        "lat" => -12.831199035192768,
        "zoom" => 11
      }
    ]
  end

  def mentions_legales
  end

  def privacy
  end

  def algorithme
    @faq_item = FaqItem.find_by(title: "Comment fonctionne la sélection des volontaires ?")
  end

  def faq
    @faq_items = FaqItem.where(area: "main")
  end

  def faq_pro
    @faq_items = FaqItem.where(area: "pro")
  end

  def robots
    render "pages/robots", layout: false, content_type: "text/plain"
  end

  StaticPage.all.each do |page|
    page_slug = page.slug.underscore

    define_method page_slug do
      page_slug_as_string = page_slug.to_s

      case page_slug_as_string
      when "cookies"
        @meta_title = "Notre politique liées aux cookies"
      when "mentions_legales"
        @meta_title = "Mentions légales - Covidliste"
      when "cgu_volontaires"
        @meta_title = "CGU - Volontaires - Covidliste"
      when "cgu_pro"
        @meta_title = "CGU - Professionnels de santé - Covidliste"
      when "privacy_volontaires"
        @meta_title = "Protection des données - Volontaires - Covidliste"
      when "privacy_pro"
        @meta_title = "Protection des données - Professionnels de santé - Covidliste"
      end

      @body = page.body
      render "pages/static"
    end
  end

  private

  def set_counters
    @users_count = Rails.cache.fetch(:users_count, expires_in: 5.minutes) { User.count }
    @users_count = 841160
    @confirmed_matched_users_count = Rails.cache.fetch(:confirmed_matched_users_count, expires_in: 5.minutes) { Match.confirmed.count }
    @confirmed_matched_users_count = 4009
    @matched_users_count = Rails.cache.fetch(:matched_users_count, expires_in: 5.minutes) { Match.distinct.count("user_id") + Match.confirmed.count }
    @matched_users_count = 76258
    @vaccination_centers_count = Rails.cache.fetch(:vaccination_centers_count, expires_in: 5.minutes) { VaccinationCenter.confirmed.count }
    @vaccination_centers_count = 936
  end

  def skip_pundit?
    true
  end
end
