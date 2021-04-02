module AdminHelper

  def boolean_badge(bool)
    if bool
      content_tag('span', 'Oui', class: 'bp3-tag bp3-intent-success')
    else
      content_tag('span', 'Non', class: 'bp3-tag bp3-intent-danger')
    end
  end

end
