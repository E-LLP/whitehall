class EditionCollectionPresenter
  def initialize(array, context)
    @array = array
    @context = context
  end

  # rubocop:disable Style/MethodMissingSuper
  # rubocop:disable Style/MissingRespondToMissing

  def method_missing(method, *args, &block)
    wrap_result(@array.__send__(method, *args, &block))
  end

  # rubocop:enable Style/MethodMissingSuper
  # rubocop:enable Style/MissingRespondToMissing

  def respond_to?(method)
    @array.respond_to?(method)
  end

  def each
    @array.each { |r| yield wrap_result(r) }
  end

private

  def wrap_result(result)
    if result.is_a?(Enumerable)
      result.map { |r| wrap_result(r) }
    elsif (presenter = presenter_for(result))
      presenter.new(result, @context)
    else
      result
    end
  end

  def presenter_for(edition)
    case edition
    when Publicationesque
      PublicationesquePresenter
    when Speech
      SpeechPresenter
    when NewsArticle
      NewsArticlePresenter
    when DetailedGuide
      DetailedGuidePresenter
    when CaseStudy
      CaseStudyPresenter
    when FatalityNotice
      FatalityNoticePresenter
    when WorldLocationNewsArticle
      WorldLocationNewsArticlePresenter
    when Announcement
      AnnouncementPresenter
    end
  end
end
