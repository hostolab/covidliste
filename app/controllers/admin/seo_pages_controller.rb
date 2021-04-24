module Admin
  class SeoPagesController < BaseController
    before_action :skip_policy_scope
    before_action :set_seo_page, only: %i[show edit update destroy]

    def index
      @seo_pages = policy_scope(SeoPage).all
    end

    def new
      authorize(SeoPage)

      @seo_page = SeoPage.new
    end

    def show
    end

    def create
      authorize(SeoPage)

      @seo_page = SeoPage.new(seo_page_params)

      if @seo_page.save
        redirect_to admin_seo_pages_path, notice: "L'article a bien été crée."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @seo_page.update(seo_page_params)
        redirect_to edit_admin_seo_page_path(@seo_page), notice: "L'article a bien été modifié."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @seo_page.destroy
        redirect_to admin_seo_pages_path, notice: "L'article a bien été supprimé."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_seo_page
      @seo_page = SeoPage.with_rich_text_content_and_embeds.find_by!(slug: params[:id])
      authorize(@seo_page)
    end

    def seo_page_params
      params.require(:seo_page).permit(:status, :title, :slug, :content, :seo_title, :seo_description, :crawlable, :indexable)
    end
  end
end
