class Sponsor < FrozenRecord::Base
  self.backend = FrozenRecord::Backends::Json

  add_index :name, unique: true
end
