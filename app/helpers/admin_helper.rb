module AdminHelper
  def boolean_badge(bool)
    if bool
      content_tag("span", "Oui")
    else
      content_tag("span", "Non")
    end
  end
end
