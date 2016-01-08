require "test_helper"
require "data_hygiene/policy_tagger"

class PolicyTaggerTest < ActiveSupport::TestCase
  setup do
    @content_id_1 = SecureRandom.uuid
    @content_id_2 = SecureRandom.uuid
    @published_edition = create(:published_publication)
    @document = @published_edition.document
    @draft_edition = create(:draft_publication, document: @document)
    stub_registration
  end

  test "updates policies for all editions of the document" do
    assert_equal [], @published_edition.reload.policy_content_ids
    assert_equal [], @draft_edition.reload.policy_content_ids

    policies_to_add = [@content_id_1, @content_id_2]
    PolicyTagger.new(
      slug:               @document.slug,
      policies_to_remove: [],
      policies_to_add:    policies_to_add,
    ).process

    assert_equal [@content_id_1, @content_id_2], @published_edition.reload.policy_content_ids
    assert_equal [@content_id_1, @content_id_2], @draft_edition.reload.policy_content_ids

    policies_to_remove = [@content_id_1, @content_id_2]
    PolicyTagger.new(
      slug:               @document.slug,
      policies_to_remove: policies_to_remove,
      policies_to_add:    [],
    ).process

    assert_equal [], @published_edition.reload.policy_content_ids
    assert_equal [], @draft_edition.reload.policy_content_ids
  end

  test "logs a warning and returns if a document cannot be found" do
    log_output = StringIO.new("")
    assert_nothing_raised do
      PolicyTagger.new(
        slug: "foo",
        policies_to_remove: [],
        policies_to_add: [],
        logger: Logger.new(log_output)
      ).process
    end

    assert_match /warning/, log_output.string
  end

  test "re-registers the published edition" do
    Whitehall::PublishingApi.expects(:republish_async).with(@published_edition)
    ServiceListeners::SearchIndexer.expects(:new).with(@published_edition)
      .returns(mock(index!: true))
    ServiceListeners::PanopticonRegistrar.expects(:new).with(@published_edition)
      .returns(mock(register!: true))

    policies_to_add = [@content_id_1, @content_id_2]
    PolicyTagger.new(
      slug:               @document.slug,
      policies_to_remove: [],
      policies_to_add:    policies_to_add,
    ).process
  end

  test "registers nothing if there are no published editions" do
    @published_edition.destroy
    Whitehall::PublishingApi.expects(:republish_async).never
    ServiceListeners::SearchIndexer.expects(:new).never
    ServiceListeners::PanopticonRegistrar.expects(:new).never

    PolicyTagger.new(slug: @document.slug, policies_to_remove: [], policies_to_add: []).process
  end

  def stub_registration
    Whitehall::PublishingApi.stubs(:republish_async)
    ServiceListeners::SearchIndexer.any_instance.stubs(:index!)
    ServiceListeners::PanopticonRegistrar.any_instance.stubs(:register!)
  end
end
