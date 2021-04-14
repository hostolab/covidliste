class Blazer::RunBlazerChecksJob < ApplicationJob
  queue_as :low

  def perform(args)
    Blazer.run_checks(schedule: args[:schedule])
  end
end
