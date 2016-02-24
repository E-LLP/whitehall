class PublishingApiPresenters::CaseStudy < PublishingApiPresenters::Edition
  def links
    {
      lead_organisations: edition.lead_organisations.map(&:content_id).select(&:present?),
      related_policies: policy_content_ids,
      supporting_organisations: edition.supporting_organisations.map(&:content_id).select(&:present?),
      document_collections: edition.published_document_collections.map(&:content_id).select(&:present?),
      world_locations: edition.world_locations.map(&:content_id).select(&:present?),
      worldwide_organisations: edition.worldwide_organisations.map(&:content_id).select(&:present?),
      worldwide_priorities: edition.worldwide_priorities.map(&:content_id).select(&:present?),
    }
  end

private
  def document_format
    "case_study"
  end

  def details
    super.merge({
      body: body,
      format_display_type: item.display_type_key,
      first_public_at: first_public_at,
      change_history: item.change_history.as_json,
    }).tap do |json|
      json[:image] = image_details if image_available?
      json[:withdrawn_notice] = withdrawn_notice if item.withdrawn?
    end
  end

  def first_public_at
    if item.document.published?
      item.first_public_at
    else
      item.document.created_at.iso8601
    end
  end

  def image_details
    {
      url: Whitehall.public_asset_host + presented_case_study.lead_image_path,
      alt_text: presented_case_study.lead_image_alt_text,
      caption: presented_case_study.lead_image_caption,
    }
  end

  def withdrawn_notice
    {
      explanation: unpublishing_explanation,
      withdrawn_at: item.updated_at
    }
  end

  def body
    Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
  end

  def unpublishing_explanation
    if item.unpublishing.try(:explanation).present?
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.unpublishing.explanation)
    end
  end

  def image_available?
    item.images.any? || lead_organisation_default_image_available?
  end

  def lead_organisation_default_image_available?
    item.lead_organisations.first.default_news_image.present?
  end

  def presented_case_study
    CaseStudyPresenter.new(item)
  end

  def policy_content_ids
    edition.policy_content_ids.select(&:present?)
  end
end
