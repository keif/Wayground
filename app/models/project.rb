require 'authority_controlled'
require 'filename_validator'

# A grouping of Memberships (typically Users or EmailAddresses),
# and various items (Events, Pages, Tasks, etc.).
class Project < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Projects', item_authority_flag_field: :always_viewable

  # The optional parent Project of this Project. The Project is a sub-project if it has a parent.
  belongs_to :parent, class_name: 'Project'
  # The User who originally created the Project. Never changes.
  belongs_to :creator, class_name: 'User'
  # The current owner of the Project.
  belongs_to :owner, class_name: 'User'

  validates :creator_id, presence: true
  validates :owner_id, presence: true
  validates :name, presence: true
  validates :filename, filename: true, length: { in: 0..127 }, uniqueness: true, allow_blank: true

  default_scope { order('name') }
end
