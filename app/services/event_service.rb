# frozen_string_literal: true

require_relative '../models/event'
require_relative '../models/event_google'
require_relative './calendar_service'
require 'date'

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
      Event.where(calendar_id: calendar_id).all
    end

    # Delete Event by id
    def self.delete(calendar_id:, event_id:)
      event = get(calendar_id: calendar_id, event_id: event_id)
      event ? event.destroy : raise('Event not found')
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
      event.start_date_time = DateTime.parse(event_google.start.date || event_google.start.date_time)
      event.start_time_zone = event_google.start.time_zone
      event.end_date_time = DateTime.parse(event_google.end.date || event_google.end.date_time)
      event.end_time_zone = event_google.end.time_zone

      create(calendar_id, event)
    end

    # Compare all the events to find common busy time
    def self.common_busy_time(events_arr) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return [] if events_arr.nil? || events_arr.length.zero?

      sorted_events_arr = events_arr.sort_by(&:start_date_time)

      first_event = Event.new
      first_event.start_date_time = sorted_events_arr.first.start_date_time
      first_event.end_date_time = sorted_events_arr.first.end_date_time
      busy_time = [first_event]

      sorted_events_arr.each do |event|
        next if event.start_date_time >= busy_time.last.start_date_time &&
                event.end_date_time <= busy_time.last.end_date_time

        if event.start_date_time > busy_time.last.end_date_time
          busy_event = Event.new
          busy_event.start_date_time = event.start_date_time
          busy_event.end_date_time = event.end_date_time

          busy_time.push(busy_event)
        else
          busy_time.last.end_date_time = event.end_date_time
        end
      end

      busy_time
    end
  end
end
