module ApplicationHelper

  def message_flash(key, value)
    type = {
      'success': 'success',
      'error': 'danger',
      'alert': 'warning',
      'notice': 'primary',
    }[key.to_sym]
    content_tag(
      'div',
      nil,
      class: "alert alert-#{type}",
      role:  'alert',
      style: 'position: inherit'
    ) do
      concat(value)
    end
  end

  def twitter_share
    url = 'https://twitter.com/share?url=Je%20viens%20de%20m%27inscrire%20sur%20%40covidliste%20pour%20recevoir%20une%20alerte%20d%C3%A8s%20qu%27une%20dose%20de%20vaccin%20sera%20disponible%20pr%C3%A8s%20de%20chez%20moi%20!%20%F0%9F%92%89%0A%0APour%20s%27inscrire%20%3A%20https%3A%2F%2Fwww.covidliste.com%2F%0A%0A%23AucuneDosePerdue'
    link_to(
      content_tag(:i, '', class: "fab fa-twitter") + 'Partager sur Twitter',
      url,
      target: "_blank",
      class:  'btn twitter-share-button'
    )
  end
end
