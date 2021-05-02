# frozen_string_literal: true

require 'json'
require 'sequel'

# CalendarCoordinator
module CalendarCoordinator
  # Event Entity
  class Event < Sequel::Model
    # Enable primary key setter
    unrestrict_primary_key

    # Defind relationships between models
    many_to_one :calendar
    plugin :association_dependencies, calendar: :destroy

    # Auto set created_at & updated_at
    plugin :timestamps

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :gid, :summary, :status, :description, :location,
                        :start_date, :start_date_time, :start_time_zone,
                        :end_date, :end_date_time, :end_time_zone

    # Secure getters and setters
    def gid
      SecureDB.decrypt(gid_secure)
    end

    def gid=(plaintext)
      self.gid_secure = SecureDB.encrypt(plaintext)
    end

    def summary
      SecureDB.decrypt(summary_secure)
    end

    def summary=(plaintext)
      self.summary_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def location
      SecureDB.decrypt(location_secure)
    end

    def location=(plaintext)
      self.location_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          id: id,
          gid: gid,
          status: status,
          summary: summary,
          description: description,
          location: location,
          start_date: start_date,
          start_date_time: start_date_time,
          start_time_zone: start_time_zone,
          end_date: end_date,
          end_date_time: end_date_time,
          end_time_zone: end_time_zone
        },
        options
      )
    end
  end
end
