module MetaTagsHelper
  def meta_title(meta)
    meta.presence || "Covidliste - Sauvons nos doses de vaccin 💉"
  end

  def meta_description(meta)
    meta.presence || "Soyez alertés si une dose est disponible près de chez vous."
  end

  def meta_image(meta)
    meta.presence || image_url("meta/main.png")
  end

  def meta_url(meta)
    meta.presence || request.original_url.force_encoding("utf-8")
  end
end
