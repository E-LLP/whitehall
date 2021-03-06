class SpecialistSectorCleanup
  def initialize(slug)
    @slug = slug
  end

  def any_taggings?
    taggings.any?
  end

  def any_published_taggings?
    taggings.map(&:edition).compact.any? do |edition|
      edition.document.ever_published_editions.any?
    end
  end

  def remove_taggings(add_note: true)
    taggings.each do |tagging|
      edition = tagging.edition
      if edition
        puts "Removing tagging to edition ##{edition.id}"
      else
        puts "Removing orphaned tagging to edition_id ##{tagging.edition_id}"
      end

      tagging.destroy

      if add_note && edition
        puts "Adding an editorial note from the GDS user"

        gds_user = User.find_by(email: "govuk-whitehall@digital.cabinet-office.gov.uk")
        edition.editorial_remarks.create!(
          author: gds_user,
          body: "Automatically untagged from old sector '#{@slug}'"
        )
      end
    end
  end

private

  def taggings
    SpecialistSector.where(tag: @slug)
  end
end
