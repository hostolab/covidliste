class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :update]

  def show
  end

  def update
    @match.confirm!
    render action: "show"
  end

  private

  def set_match
    @match = Match.find_by(match_confirmation_token: params[:match_confirmation_token])
  end
end
