# frozen_string_literal: true

require 'roda'
require_relative './app'

module CalendarCoordinator
  # API for groups route
  class API < Roda
    route('google') do |routing|
      routing.on 'calendar' do
        routing.on String do |calendar_gid|
          routing.on 'events' do
            # POST /api/v1/google/calendar/{calendar_gid}/events
            routing.post do
              google_events = JSON.parse(routing.body.read, object_class: OpenStruct)
              EventService.save_from_google(Base64.strict_decode64(calendar_gid), google_events)
              routing.halt 201, { message: 'Event saved' }.to_json
            rescue Sequel::MassAssignmentRestriction => e
              API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
              routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
            rescue StandardError => e
              puts e.full_message
              API.logger.error "UNKOWN ERROR: #{e.message}"
              routing.halt 500, { message: e.message }.to_json
            end
          end
        end
      end
    end
  end
end
