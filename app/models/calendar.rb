# frozen_string_literal: true

require 'json'
require 'sequel'

# CalendarCoordinator
module CalendarCoordinator
  # Calendar Class
  class Calendar < Sequel::Model
    # Defind relationships between models
    one_to_many :events
    many_to_one :belonged_accounts, class: :'CalendarCoordinator::Account'

    plugin :association_dependencies,
           events: :destroy

    # Auto set created_at & updated_at
    plugin :timestamps

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :summary, :description, :location, :time_zone, :access_role

    # Secure getters and setters
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
