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
                event = Event.where(calendar_id: calendar_id, event_id: event_id).first
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
                event = Event.create(data)

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
          end

          # GET /api/v1/calendars/{id}
          routing.get String do |calendar_id|
            response.status = 200
            Calendar.find(calendar_id).to_json
          rescue StandardError
            routing.halt 404, { message: 'Calendar not found' }.to_json
          end

          # GET /api/v1/calendars
          routing.get do
            response.status = 200
            JSON.pretty_generate(Calendar.all)
          rescue StandardError
            routing.halt 500, { message: 'Server error' }.to_json
          end

          # POST /api/v1/calendars
          routing.post do
            # puts "body: #{JSON.parse(routing.body.read)}"
            data = JSON.parse(routing.body.read)
            calendar = Calendar.new(data)

            if calendar.save
              response.status = 201
              { message: 'Calendar saved', calendar_id: calendar.id }.to_json
            else
              routing.halt 400, { message: 'Save Calendar failed' }.to_json
            end
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
