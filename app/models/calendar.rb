# frozen_string_literal: true

require 'json'
require 'sequel'

# CalendarCoordinator
module CalendarCoordinator
  # Calendar Class
  class Calendar < Sequel::Model
    # Enable primary key setter

    # Defind relationships between models
    one_to_many :event
    plugin :association_dependencies, event: :destroy

    # Auto set created_at & updated_at
    plugin :timestamps

    plugin :uuid, field: :id

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          id: id,
          summary: summary,
          description: description,
          location: location,
          time_zone: time_zone,
          access_role: access_role
        },
        options
      )
    end
  end
end
