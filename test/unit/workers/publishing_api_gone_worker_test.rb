require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiGoneWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @uuid = SecureRandom.uuid
  end

  test "publishes a 'gone' item for the supplied content id" do
    request = stub_publishing_api_unpublish(
      @uuid,
      body: { type: "gone", locale: "de" }
    )

    PublishingApiGoneWorker.new.perform(@uuid, "de")

    assert_requested request
  end
end
