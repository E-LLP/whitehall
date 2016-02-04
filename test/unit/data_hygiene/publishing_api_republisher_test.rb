require 'test_helper'

class DataHygiene::PublishingApiRepublisherTest < ActiveSupport::TestCase
  test "republishes a model to the Publishing API" do
    organisation     = create(:organisation)
    scope            = Organisation.where(id: organisation.id)
    presenter        = PublishingApiPresenters.presenter_for(organisation, update_type: "republish")
    WebMock.reset!

    expected_requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_put_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: 'en', update_type: 'republish')
    ]

    DataHygiene::PublishingApiRepublisher.new(scope, NullLogger.instance).perform

    assert_all_requested(expected_requests)
  end
end
