# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative '../services/calendar_service'
require_relative '../services/event_service'

module CalendarCoordinator
  # API for groups route
  class API < Roda
    route('calendars') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on String do |calendar_id| # rubocop:disable Metrics/BlockLength
        routing.on 'events' do # rubocop:disable Metrics/BlockLength
          # GET /api/v1/calendars/{calendar_id}/events/{event_id}
          routing.get String do |event_id|
            response.status = 200
            event = EventService.get(calendar_id: calendar_id, event_id: event_id)
            event ? event.to_json : raise('Event not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET /api/v1/calendars/{calendar_id}/events
          routing.get do
            response.status = 200
            events = EventService.all(calendar_id: calendar_id)
            JSON.pretty_generate(events)
          rescue StandardError => e
            routing.halt 500, { message: e.full_message }.to_json
          end

          # POST /api/v1/calendars/{calendar_id}/events
          routing.post do
            data = JSON.parse(routing.body.read)
            event = EventService.create(calendar_id: calendar_id, data: data)
            if event
              response.status = 201
              { message: 'Event saved', event_id: event.id }.to_json
            else
              routing.halt 400, { message: 'Save Event failed' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction => e
            API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
            routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
          rescue StandardError => e
            API.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: e.message }.to_json
          end
        end
        # GET /api/v1/calendars/{id}
        routing.get do
          response.status = 200
          calendar = CalendarService.get(id: calendar_id)
          calendar ? calendar.to_json : raise('Calendar not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end
      # GET /api/v1/calendars
      routing.get do
        response.status = 200
        JSON.pretty_generate(CalendarService.all)
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
