module Edition::NationalApplicability
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.nation_inapplicabilities.each do |na|
        edition.nation_inapplicabilities.build(na.attributes.except("id"))
      end
    end
  end

  included do
    has_many :nation_inapplicabilities, foreign_key: :edition_id, dependent: :destroy, autosave: true
    validates_associated :nation_inapplicabilities

    add_trait Trait
  end

  def nation_inapplicabilities_attributes=(attributes)
    attributes.each do |index, params|
      existing = nation_inapplicabilities.detect { |ni| ni.nation_id == params[:nation_id].to_i }

      if ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:excluded])
        if existing
          existing.attributes = params.except(:excluded, :id)
        else
          nation_inapplicabilities.build(params)
        end
      else
        if existing
          existing.mark_for_destruction
          existing.excluded = params[:excluded]
        end
      end
    end
  end

  def inapplicable_nations
    nation_inapplicabilities.map(&:nation)
  end

  def applicable_nations
    Nation.all - inapplicable_nations
  end

  def can_apply_to_subset_of_nations?
    true
  end
end
