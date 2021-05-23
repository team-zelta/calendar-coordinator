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

    many_to_many :belonged_groups,
                 class: :'CalendarCoordinator::Group',
                 join_table: :calendars_groups,
                 left_key: :calendar_id, right_key: :group_id

    plugin :association_dependencies, events: :destroy,
                                      belonged_groups: :nullify

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
          account_id: account_id,
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
