# NB: Topic is being renamed to "Policy Area" across GOV.UK.
class Topic < Classification
  has_many :featured_links, -> { order(:created_at) },  as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :featured_links, reject_if: -> attributes { attributes['url'].blank? }, allow_destroy: true
  has_many :statistics_announcement_topics, inverse_of: :topic

  def self.with_statistics_announcements
    joins(:statistics_announcement_topics)
      .group('statistics_announcement_topics.topic_id')
  end
end
