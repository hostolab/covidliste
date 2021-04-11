FrozenRecord::Base.base_path = Rails.root.join("db", "frozen_records")
FrozenRecord::Base.auto_reloading = Rails.env.development?
FrozenRecord.deprecated_yaml_erb_backend = false
