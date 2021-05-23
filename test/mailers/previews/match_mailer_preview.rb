# frozen_string_literal: true

class MatchMailerPreview < ActionMailer::Preview
  def match_confirmation_instructions
    match = FactoryBot.create(:match, :available)
    MatchMailer.with(match: match).match_confirmation_instructions.deliver_now
  end

  def match_confirmation_instructions_multi_match
    match = FactoryBot.create(:match_multi, :available)
    match_fill_campaign = FactoryBot.create(:match_multi, :confirmed, :campaign => match.campaign)
    match_new_campaign = FactoryBot.create(:match_multi, :available, :user => match.user)
    MatchMailer.with(match: match).match_confirmation_instructions.deliver_now
  end

  def send_anonymisation_notice
    match = FactoryBot.create(:match, :confirmed)
    MatchMailer.with(match: match).send_anonymisation_notice.deliver_now
  end

  def send_confirmed_match_details
    match = FactoryBot.create(:match, :confirmed)
    MatchMailer.with(match: match).send_confirmed_match_details.deliver_now
  end
end
