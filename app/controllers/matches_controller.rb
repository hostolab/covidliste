class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :update]

  def show
    if @match.confirmed?
      flash[:success] = "Votre confirmation a bien été prise en compte. Le centre attend votre venue."
    elsif @match.expires_at < Time.now.utc
      flash[:alert] = "Le délai de confirmation est dépassé, nous avons dû contacter un autre volontaire."
      redirect_to root_path
    end
  end

  def update
    if @match.expires_at > Time.now.utc
      @match.update(confirmed_at: Time.now.utc)
      flash[:success] = "Votre confirmation a bien été prise en compte. Le centre attend votre venue."
      redirect_to match_path(@match)
    else
      flash[:alert] = "Le délai de confirmation est dépassé, nous avons dû contacter un autre volontaire."
      redirect_to root_path
    end
  end

  private

  def set_match
    @match = Match.find_by(params[:token])
  end
end
