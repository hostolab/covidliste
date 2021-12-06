class VmdParserService
  include HTTParty
  base_uri "https://vitemadose.gitlab.io/vitemadose"

  def parse
    slots.each do |slot|
      VmdSlot.build_from_hash(slot, last_updated_at)
    end
  end

  def slots
    @slots ||= data["centres_disponibles"]
  end

  def last_updated_at
    @last_updated_at ||= data["last_updated"].to_datetime
  end

  def data
    @data ||= self.class.get("/info_centres.json")
  end

end
