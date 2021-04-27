module ApplicationHelper
  include Pagy::Frontend

  def message_flash(key, value)
    type = {
      success: "success",
      error: "danger",
      alert: "warning",
      notice: "primary"
    }[key.to_sym]
    content_tag(
      "div",
      nil,
      class: "alert alert-#{type}",
      role: "alert",
      style: "position: inherit"
    ) do
      concat(value)
    end
  end

  def twitter_share
    url = "https://twitter.com/share?url=Je%20viens%20de%20m%27inscrire%20sur%20%40covidliste%20pour%20recevoir%20une%20alerte%20d%C3%A8s%20qu%27une%20dose%20de%20vaccin%20sera%20disponible%20pr%C3%A8s%20de%20chez%20moi%20!%20%F0%9F%92%89%0A%0APour%20s%27inscrire%20%3A%20https%3A%2F%2Fwww.covidliste.com%2F%0A%0A%23AucuneDosePerdue"
    link_to(
      content_tag(:i, "", class: "fab fa-twitter") + "Partager sur Twitter",
      url,
      target: "_blank",
      class: "btn twitter-share-button"
    )
  end

  def humanize_boolean(boolean)
    if boolean
      icon("fas", "check", class: "text-success")
    else
      icon("fas", "times", class: "text-danger")
    end
  end

  def pretty_number(number)
    return "" if number.blank?
    ActionController::Base.helpers.number_with_delimiter(number, locale: :fr).gsub(" ", "&nbsp;").html_safe
  end

  def distance_delta(p1, p2)
    distance = Geocoder::Calculations.distance_between([p1[:lat], p1[:lon]], [p2[:lat], p2[:lon]], {unit: :km})
    if distance < 1
      distance = (distance.round(2) * 1000).round(-1)
      distance_in_words = "#{distance} m"
    else
      distance = distance.round(1)
      distance_in_words = "#{distance.round(1)} km"
    end
    {
      delta: distance,
      delta_in_words: distance_in_words
    }
  end
end
