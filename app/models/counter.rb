class Counter < ApplicationRecord
  def self.increment(key)
    counter = Counter.find_or_initialize_by(key: key)
    counter.with_lock do
      counter.value += 1
      counter.save
    end
  end
end
