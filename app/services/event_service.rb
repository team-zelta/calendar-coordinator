# frozen_string_literal: true

require_relative '../models/event'
require_relative '../models/event_google'
require_relative './calendar_service'

# CalendarCoordinator
module CalendarCoordinator
  # Event Service
  class EventService
    include GoogleCalendar
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
    def self.all(calendar_id:)
      Event.where(calendar_id: calendar_id).first
    end

    # Get list from google and insert into database
    def self.list_from_google(calendar_id:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      event_google = EventGoogle.list

      event = Event.new
      event.gid = event_google.gid
      event.summary = event_google.summary
      event.status = event_google.status
      event.description = event_google.description
      event.location = event_google.location
      event.start_date = event_google.start.date
      event.start_date_time = event_google.start.date_time
      event.start_time_zone = event_google.start.time_zone
      event.end_date = event_google.end.date
      event.end_date_time = event_google.end.date_time
      event.end_time_zone = event_google.end.time_zone

      create(calendar_id, event)
    end
  end
end
