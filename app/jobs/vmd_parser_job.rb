class VmdParserJob < ApplicationJob
  queue_as :critical

  def perform
    VmdParserService.new.parse
  end
end
