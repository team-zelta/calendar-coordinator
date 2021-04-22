# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/event'
require_relative '../models/my_calendar'

# Calendar
module Calendar
  # WebAPI controller
  class API < Roda
    plugin :environments
    plugin :halt

    configure do
      Event.setup
      MyCalendar.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Calendar API up at /api/v1' }.to_json
      end

      routing.on 'api' do # rubocop:disable Metrics/BlockLength
        routing.on 'v1' do # rubocop:disable Metrics/BlockLength
          routing.on 'events' do
            # GET /api/v1/events/{id}
            routing.get String do |id|
              response.status = 200
              Event.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Event not found' }.to_json
            end

            # GET /api/v1/events
            routing.get do
              response.status = 200
              JSON.pretty_generate(Event.all)
            rescue StandardError
              routing.halt 500, { message: 'Server error' }.to_json
            end

            # POST /api/v1/events
            routing.post do
              data = JSON.parse(routing.body.read)
              event = Event.new(data)

              if event.save
                response.status = 201
                { message: 'Event saved', event_id: event.id }.to_json
              else
                routing.halt 400, { message: 'Save Event failed' }.to_json
              end
            end
          end

          routing.on 'calendars' do
            # GET /api/v1/calendars/{id}
            routing.get String do |id|
              response.status = 200
              MyCalendar.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Calendar not found' }.to_json
            end

            # GET /api/v1/calendars
            routing.get do
              response.status = 200
              JSON.pretty_generate(MyCalendar.all)
            rescue StandardError
              routing.halt 500, { message: 'Server error' }.to_json
            end

            # POST /api/v1/calendars
            routing.post do
              # puts "body: #{JSON.parse(routing.body.read)}"
              data = JSON.parse(routing.body.read)
              calendar = MyCalendar.new(data)

              if calendar.save
                response.status = 201
                { message: 'Calendar saved', calendar_id: calendar.id }.to_json
              else
                routing.halt 400, { message: 'Save Calendar failed' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
