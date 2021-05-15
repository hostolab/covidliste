class VmdParserJob < ApplicationJob
  queue_as :low

  def perform
    VmdParserService.new.parse
  end
end
