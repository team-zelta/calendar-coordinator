# frozen_string_literal: true

require_relative '../models/calendar'
require_relative './account_service'

# CalendarCoordinator
module CalendarCoordinator
  # Calendar Service
  class CalendarService
    # Create Calendar
    def self.create(account_id:, calendars:)
      account = AccountService.get(id: account_id)
      calendars.each do |calendar|
        account.add_owned_calendar(calendar)
      end
    end

    # Get Calendar by id
    def self.get(id:)
      Calendar.find(id: id)
    end

    # Get all Calendar
    def self.all
      Calendar.all
    end

    # Delete Calendar by id
    def self.delete(id:)
      calendar = get(id: id)
      calendar ? calendar.destroy : raise('Calendar not found')
    end

    # Get owned Events
    def self.owned_events(id:)
      get(id: id).events
    end

    # Get belonged Accounts
    def self.belonged_accounts(id:)
      calendar = get(id: id)
      AccountService.get(id: calendar.account_id)
    end

    # Get owned Events filter by require date
    def self.owned_events_by_date(id:, mode:, date:)
      # day or week
      mode_time = mode == 'day' ? 1 : 7

      puts Event.where(calendar_id: id)
      Event.where(calendar_id: id)
           .exclude { end_date_time <= DateTime.parse(date) }
           .exclude { start_date_time >= DateTime.parse(date) + mode_time }
           .all
    end

    # Update Calendar
    def self.update(id:, data:)
      Calendar.where(id: id).each { |calendar| calendar.update(data) }
    end
  end
end
