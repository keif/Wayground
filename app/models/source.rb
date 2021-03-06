# Sources for data, linking to processors to use to generate local items from that data.
# Types of sources might include RSS feeds, iCalendars, APIs, microformat scrapings, etc.
# May be dynamically maintained so the local items generated from the Source
# can be updated based on changes to the Source.
class Source < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Source', item_authority_flag_field: :always_private

  belongs_to :container_item, polymorphic: true
  belongs_to :datastore
  has_many :sourced_items, dependent: :delete_all

  before_validation :set_defaults, on: :create

  validates :processor, inclusion: { in: %w(iCalendar IcalProcessor) }
  validates :method, inclusion: { in: %w(get post) }
  # allow urls, or references to the testing fixture files
  validates(
    :url,
    format: {
      with: %r{\A(([a-z]+:/+[^ \r\n\t]+)|([/A-Za-z0-9_]+/)?spec/fixtures/files/[a-z0-9_\-]+\.[a-z0-9]+)\z},
      message: 'must begin with a valid URL (starting with ‘http://’ or equivalent)'
    }
  )
  validate :validate_dates

  # Set default values for the Source. Should only be called once on create.
  def set_defaults
    self.method = 'get' unless method?
  end

  # last_update_at should not be set in the future.
  def validate_dates
    if last_updated_at? && (last_updated_at.to_datetime > Time.zone.now.to_datetime)
      errors.add(:last_updated_at, 'must not be in the future')
    end
  end

  # Get a human readable string to describe the Source.
  def name
    if title?
      title
    else
      "Source #{id}"
    end
  end

  # Run the processor defined by this Source.
  def run_processor(user = nil, approve = false)
    run_icalendar_processor(user, approve) if %w(iCalendar IcalProcessor).include?(processor)
  end

  def run_icalendar_processor(user, approve)
    processed = Wayground::Import::IcalImporter.process_source(self, user: user, approve: approve)
    self.last_updated_at = Time.zone.now
    save
    processed
  end
end
