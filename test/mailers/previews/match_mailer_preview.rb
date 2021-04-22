# frozen_string_literal: true

class MatchMailerPreview < ActionMailer::Preview
  def match_confirmation_instructions
    match = FactoryBot.create(:match, :available)
    MatchMailer.with(match: match).match_confirmation_instructions.deliver_now
  end

  def send_anonymisation_notice
    match = FactoryBot.create(:match, :confirmed)
    MatchMailer.with(match: match).send_anonymisation_notice.deliver_now
  end
end
