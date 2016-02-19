require 'test_helper'

class DataHygiene::PublishingApiDocumentRepublisherTest < ActiveSupport::TestCase
  test "republishes a model to the Publishing API" do
    case_study = create(:published_case_study)
    presenter  = PublishingApiPresenters.presenter_for(case_study, update_type: "republish")
    WebMock.reset!

    expected_requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_put_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: 'en', update_type: 'republish')
    ]

    DataHygiene::PublishingApiDocumentRepublisher.new(CaseStudy, NullLogger.instance).perform

    assert_all_requested(expected_requests)
  end

  test "republishes an unpublishing for unpublished-with-notice editions, followed by the draft" do
    unpublishing = create(:unpublishing)
    edition = unpublishing.edition
    unpub_presenter = PublishingApiPresenters.presenter_for(unpublishing, update_type: "republish")
    draft_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    WebMock.reset!

    puts "unpublishing.content_id #{unpublishing.content_id}"
    puts "edition.content_id #{edition.content_id}"

    expected_requests = [
      stub_publishing_api_put_content(unpub_presenter.content_id, unpub_presenter.content),
      stub_publishing_api_put_links(unpub_presenter.content_id, links: unpub_presenter.links),
      stub_publishing_api_publish(unpub_presenter.content_id, locale: 'en', update_type: 'republish'),

      stub_publishing_api_put_content(draft_presenter.content_id, draft_presenter.content),
      stub_publishing_api_put_links(draft_presenter.content_id, links: draft_presenter.links),
      stub_publishing_api_publish(draft_presenter.content_id, locale: 'en', update_type: 'republish')
    ]

    DataHygiene::PublishingApiDocumentRepublisher.new(CaseStudy, NullLogger.instance).perform

    assert_all_requested(expected_requests)
  end

  test "republishes redirects for unpublished-with-redirect edition, followed by the draft" do

  end

  # TODO what about publish intents and coming soons?

  test "rejects a scope if passed in" do
    assert_raise ArgumentError do
      DataHygiene::PublishingApiDocumentRepublisher.new(CaseStudy.all)
    end
  end

  test "rejects a class that isn't a subclass of Edition" do
    assert_raise ArgumentError do
      DataHygiene::PublishingApiDocumentRepublisher.new(Organisation)
    end
  end
end
