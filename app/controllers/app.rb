# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/event'
require_relative '../models/calendar'
require_relative '../models/account'

require_relative '../services/account_service'

# Calendar
module CalendarCoordinator
  # WebAPI controller
  class API < Roda # rubocop:disable Metrics/ClassLength
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
        routing.on 'accounts' do
          # GET /api/v1/accounts/{account_id}
          routing.get String do |account_id|
            response.status = 200
            account = AccountService.get(id: account_id)
            account ? account.to_json : raise('Account not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET /api/v1/accounts
          routing.get do
            response.status = 200
            JSON.pretty_generate(AccountService.all)
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end

          # POST /api/v1/accounts
          routing.post do
            data = JSON.parse(routing.body.read)

            account = AccountService.create(data: data)
            if account
              response.status = 201
              { message: 'Account saved', account_id: account.id }.to_json
            else
              routing.halt 400, { message: 'Save Account failed' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction => e
            API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
            routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
          rescue StandardError => e
            API.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: e.message }.to_json
          end
        end

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

                calendar = Calendar.first(id: calendar_id)
                event = calendar.add_event(data)

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
              calendar = Calendar.first(id: calendar_id)
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

            calendar = Calendar.create(data)
            if calendar
              response.status = 201
              { message: 'Calendar saved', calendar_id: calendar.id }.to_json
            else
              routing.halt 400, { message: 'Save Calendar failed' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction => e
            API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
            routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
          rescue StandardError => e
            API.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: e.message }.to_json
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
