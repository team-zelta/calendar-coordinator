# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/event'
require_relative '../models/calendar'

# Calendar
module CalendarCoordinator
  # WebAPI controller
  class API < Roda
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Calendar API up at /api/v1' }.to_json
      end

      # rubocop:disable Metrics/BlockLength
      @api_v1 = 'api/v1'
      routing.on @api_v1 do
        routing.on 'calendars' do
          routing.on String do |calendar_id|
            routing.on 'events' do
              # GET /api/v1/calendars/{calendar_id}/events/{event_id}
              routing.get String do |event_id|
                response.status = 200
                event = Event.where(calendar_id: calendar_id, id: event_id).first
                event ? event.to_json : raise('Event not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET /api/v1/calendars/{calendar_id}/events
              routing.get do
                response.status = 200
                JSON.pretty_generate(Event.all)
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end

              # POST /api/v1/calendars/{calendar_id}/events
              routing.post do
                data = JSON.parse(routing.body.read)
                event_data = Event.new(data)

                # Check existed
                event = Event.where(calendar_id: calendar_id, id: event_data.id).first
                if !event.nil? && event.id == event_data.id
                  response.status = 200
                  return { message: 'Event existed', event_id: event.id }.to_json
                end

                calendar = Calendar.find(id: calendar_id)
                event = calendar.add_event(data)

                if event
                  response.status = 201
                  { message: 'Event saved', event_id: event.id }.to_json
                else
                  routing.halt 400, { message: 'Save Event failed' }.to_json
                end
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET /api/v1/calendars/{id}
            routing.get do
              response.status = 200
              calendar = Calendar.find(id: calendar_id)
              calendar ? calendar.to_json : raise('Calendar not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET /api/v1/calendars
          routing.get do
            response.status = 200
            JSON.pretty_generate(Calendar.all)
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end

          # POST /api/v1/calendars
          routing.post do
            data = JSON.parse(routing.body.read)
            calendar_data = Calendar.new(data)

            # Check existed
            calendar = Calendar.find(id: calendar_data.id)
            if !calendar.nil? && calendar.id == calendar_data.id
              response.status = 200
              return { message: 'Calendar existed', calendar_id: calendar_data.gid }.to_json
            end

            calendar = Calendar.create(data)
            if calendar
              response.status = 201
              { message: 'Calendar saved', calendar_id: calendar.id }.to_json
            else
              routing.halt 400, { message: 'Save Calendar failed' }.to_json
            end
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
