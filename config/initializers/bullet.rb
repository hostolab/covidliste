if defined? Bullet
  if ENV.fetch("DISABLE_BULLET", false) == false
    Bullet.enable = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.bullet_logger = true
    Bullet.add_footer = true
  end
end
