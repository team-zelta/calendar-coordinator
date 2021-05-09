# frozen_string_literal: true

require_relative '../models/calendar'
require_relative './account_service'

# CalendarCoordinator
module CalendarCoordinator
  # Calendar Service
  class CalendarService
    # Create Calendar
    def self.create(account_id:, data:)
      account = AccountService.get(id: account_id)
      account.add_owned_calendar(data)
    end

    # Get Calendar by id
    def self.get(id:)
      Calendar.find(id: id)
    end

    # Get all Calendar
    def self.all
      Calendar.all
    end
  end
end
