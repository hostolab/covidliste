class PagesController < ApplicationController
  def benevoles
    @volunteers = Volunteer.where(anon: false).order(sort_name: :asc) + Volunteer.where(anon: true).order(sort_name: :asc)
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
          "coordinates" => [v.approximated_lon, v.approximated_lat]
        }
      end
    end

    @users_by_dept = {}
    # @users_by_dept = Rails.cache.fetch("users_by_dept", expires_in: 1.hours) do
    #   sql = "
    #     select
    #     case
    #     when substring(geo_citycode, 1, 2) in ('2A', '2B') then substring(geo_citycode, 1, 2)
    #     when substring(geo_citycode, 1, 2)::int <= 95
    #     then substring(geo_citycode, 1, 2)
    #     else substring(geo_citycode, 1, 3) end as key,
    #     count(*) as value
    #     from users
    #     where
    #     confirmed_at is not null
    #     and geo_citycode is not null
    #     group by 1
    #     having count(*) > 100
    #     order by 2 desc
    #     "
    #   Hash[User.connection.select_all(sql).map{ |row| row.values }]
    # end
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
