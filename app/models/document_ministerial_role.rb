class DocumentMinisterialRole < ActiveRecord::Base
  belongs_to :edition
  belongs_to :ministerial_role
end