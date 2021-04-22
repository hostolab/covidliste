class Volunteer < FrozenRecord::Base
  self.backend = FrozenRecord::Backends::Json

  add_index :id, unique: true

  def picture_path
    @picture_path ||= if picture.blank?
      "covidliste.png"
    else
      "volunteers/" + picture
    end
  end

  def display_name
    @display_name ||= if anon
      "Bénévole anonyme"
    elsif firstname || lastname
      "#{firstname} #{lastname}"
    elsif nickname
      nickname
    else
      "Bénévole anonyme"
    end
  end

  def sort_name
    @sort_name ||= display_name.parameterize
  end
end
