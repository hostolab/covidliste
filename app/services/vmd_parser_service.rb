class VmdParserService
  include HTTParty
  base_uri "https://vitemadose.gitlab.io/vitemadose"

  def parse
    slots.each do |slot|
      VmdSlot.build_from_hash(slot)
    end
  end

  def data
    @data ||= self.class.get("/info_centres.json")
  end

  def slots
    @centres ||= data.map do |k, v|
      v["centres_disponibles"]
    end.flatten
  end
end
