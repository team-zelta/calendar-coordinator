# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/event'

# Calendar
module Calendar
  # WebAPI controller
  class API < Roda
    plugin :environments
    plugin :halt

    configure do
      Event.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'Calendar API up at /api/v1' }.to_json
      end

      routing.on 'api' do # rubocop:disable Metrics/BlockLength
        routing.on 'v1' do
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
        end
      end
    end
  end
end
