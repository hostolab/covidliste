class UluleBuddyOrder < FrozenRecord::Base
  self.backend = FrozenRecord::Backends::Json

  add_index :order_id, unique: true

  def picture_path
    "ulule_buddy_orders/order-#{order_id}.jpg"
  end
end
