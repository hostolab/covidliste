class Counter < ApplicationRecord
  validates :key, uniqueness: true

  def self.increment(key)
    counter = Counter.find_or_initialize_by(key: key)
    counter.with_lock do
      counter.value += 1
      counter.save
    end
  end

  def self.total_users
    Counter.find_by(key: :total_users)&.value
  end
end
