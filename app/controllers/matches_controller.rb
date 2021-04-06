class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :update]

  def show
    @period = (@match.expires_at - Time.now.utc)
    if @period <= 0
      flash[:alert] = "Le délai de confirmation est dépassé, nous avons dû contacter un autre volontaire."
      redirect_to root_path
    elsif @match.confirmed_at
      flash[:success] = "Votre confirmation a bien été prise en compte. Le centre attend votre venue."
      redirect_to match_path(@match)
    end
  end

  def update
    @match.update(confirmed_at: Time.now.utc)
    flash[:success] = "Votre confirmation a bien été prise en compte. Le centre attend votre venue."
    redirect_to match_path(@match)
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end
end
