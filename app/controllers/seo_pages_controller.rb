class SeoPagesController < ApplicationController
  before_action :set_seo_page, only: [:show]

  def show
  end

  private

  def set_seo_page
    klass = SeoPage.with_rich_text_content_and_embeds
    klass = klass.online unless current_user.admin?
    @seo_page = klass.find_by!(slug: params[:id])
  end

  def skip_pundit?
    true
  end
end
