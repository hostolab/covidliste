class Review < FrozenRecord::Base
  self.backend = FrozenRecord::Backends::Json

  add_index :from
end
