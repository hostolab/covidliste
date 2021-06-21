class PagesController < ApplicationController
  before_action :define_as_page_pro, only: [:landing_page_pro, :faq_pro]

  def landing_page_pro
    @users_count = Rails.cache.fetch(:users_count, expires_in: 30.seconds) { Counter.total_users }
    @confirmed_matched_users_count = Rails.cache.fetch(:confirmed_matched_users_count, expires_in: 30.minutes) { Match.confirmed.count }
    @vaccination_centers_count = Rails.cache.fetch(:vaccination_centers_count, expires_in: 30.minutes) { VaccinationCenter.confirmed.count }
    @typeform_url = "https://form.typeform.com/to/Gj2d2iue"
    # @typeform_url = nil # "https://form.typeform.com/to/Gj2d2iue"
    @reviews = Review.all
    # @reviews = Review.where(from: "volunteer")
    @faq_items = FaqItem.where(area: "pro").limit(4)
  end

  def benevoles
    @volunteers = Volunteer.where(old: false, anon: false).order(sort_name: :asc) + Volunteer.where(old: false, anon: true).order(sort_name: :asc)
    @old_volunteers = Volunteer.where(old: true).order(sort_name: :asc)
    @enable_recruitment = false
  end

  def donateurs
    @force = params[:force].present?
    @debug = params[:debug].present?
    @ulule_buddy_orders = UluleBuddyOrder.all.each_with_object({}) do |e, m|
      m[e.order_id] = {
        name: e.name,
        picture_path: e.picture_path
      }
    end
    data = UluleService.new("covidliste", ENV["ULULE_API_KEY"]).data(@force)
    @project = data[:project]
    @bronze_orders = data[:bronze_orders]
    @silver_orders = data[:silver_orders]
    @gold_orders = data[:gold_orders]
    @diamond_orders = data[:diamond_orders]
  end

  def sponsors
    @sponsors = Sponsor.all
  end

  def temoignages
    @reviews = Review.all
    @typeform_url = "https://form.typeform.com/to/rHTAEqUZ"
  end

  def contact
    @contact_items = FaqItem.where(category: "Collaboration et contact")
  end

  def carte
    @vaccination_centers = VaccinationCenter.confirmed

    @map_areas = [
      {
        "label" => "France métropolitaine",
        "lon" => 2.3,
        "lat" => 47.1,
        "zoom" => 5.5
      }
      # {
      #   "label" => "Guyane",
      #   "lon" => -53.02730090442361,
      #   "lat" => 4,
      #   "zoom" => 7
      # },
      # {
      #   "label" => "Guadeloupe",
      #   "lon" => -61.5,
      #   "lat" => 16.176021024448076,
      #   "zoom" => 10
      # },
      # {
      #   "label" => "La Réunion",
      #   "lon" => 55.53913649067738,
      #   "lat" => -21.153674695744286,
      #   "zoom" => 10
      # },
      # {
      #   "label" => "Martinique",
      #   "lon" => -60.97336870145841,
      #   "lat" => 14.632175285699219,
      #   "zoom" => 10
      # },
      # {
      #   "label" => "Mayotte",
      #   "lon" => 45.16242028163609,
      #   "lat" => -12.831199035192768,
      #   "zoom" => 11
      # }
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
    respond_to do |format|
      format.html
      format.json { render json: @faq_items.to_json }
    end
  end

  def faq_pro
    @faq_items = FaqItem.where(area: "pro")
    respond_to do |format|
      format.html
      format.json { render json: @faq_items.to_json }
    end
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

  def skip_pundit?
    true
  end
end
