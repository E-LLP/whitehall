class StatisticsController < DocumentsController
  enable_request_formats index: %i[json atom]
  before_action :inject_statistics_publication_filter_option_param, only: :index
  before_action :expire_cache_when_next_publication_published

  def index
    @filter = build_document_filter
    @filter.publications_search

    respond_to do |format|
      format.html do
        @content_item = Whitehall
          .content_store
          .content_item("/government/statistics")
          .to_hash

        @filter = StatisticsFilterJsonPresenter.new(
          @filter, view_context, PublicationesquePresenter
        )
      end
      format.json do
        render json: StatisticsFilterJsonPresenter.new(@filter, view_context, PublicationesquePresenter)
      end
      format.atom do
        documents = Publicationesque.published_with_eager_loading(@filter.documents.map(&:id))
        @statistics = Whitehall::Decorators::CollectionDecorator.new(
          documents.sort_by(&:public_timestamp).reverse,
          PublicationesquePresenter,
          view_context,
        )
      end
    end
  end

private

  def inject_statistics_publication_filter_option_param
    params[:publication_filter_option] = "statistics"
  end

  def expire_cache_when_next_publication_published
    expire_on_next_scheduled_publication(Publicationesque.scheduled.order("scheduled_publication asc"))
  end
end
