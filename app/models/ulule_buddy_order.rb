class UluleBuddyOrder < FrozenRecord::Base
  self.backend = FrozenRecord::Backends::Json

  add_index :order_id, unique: true

  def picture_path
    picture_pathfile = "ulule_buddy_orders/order-#{order_id}.jpg"
    ActionController::Base.helpers.image_url(picture_pathfile).present? ? picture_pathfile : false
  rescue Sprockets::Rails::Helper::AssetNotFound
    "ulule_buddy_orders/order-default.png"
  end
end
