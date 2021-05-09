# frozen_string_literal: true

require_relative '../models/event'
require_relative './calendar_service'

# CalendarCoordinator
module CalendarCoordinator
  # Event Service
  class EventService
    # Create Event
    def self.create(calendar_id:, data:)
      calendar = CalendarService.get(id: calendar_id)
      calendar.add_event(data)
    end

    # Get Event by calendar id and event id
    def self.get(calendar_id:, event_id:)
      Event.where(calendar_id: calendar_id, id: event_id).first
    end

    # Get all Event
    def self.all
      Event.all
    end
  end
end
