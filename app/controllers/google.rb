# frozen_string_literal: true

require 'roda'
require_relative './app'
require 'googleauth'
require 'google/apis/calendar_v3'

module CalendarCoordinator
  # API for groups route
  class API < Roda
    route('google') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on 'calendar' do # rubocop:disable Metrics/BlockLength
        routing.post do # rubocop:disable Metrics/BlockLength
          response.status = 200
          credentials_data = JSON.parse(routing.body.read, object_class: OpenStruct)

          credentials = GoogleCredentials.new(credentials_data).user_refresh_credentials
          google_calendar = Google::Apis::CalendarV3::CalendarService.new
          google_calendar.authorization = credentials

          # Get calendar list from Google Calendar API
          calendar_list = google_calendar.list_calendar_lists
          calendars = []
          calendar_list.items.each do |calendar|
            next unless calendar.access_role == 'owner'

            calendars.push(
              {
                gid: calendar.id,
                summary: calendar.summary,
                description: calendar.description,
                location: calendar.location,
                time_zone: calendar.time_zone,
                access_role: calendar.access_role
              }
            )
          end

          calendars.to_json
        rescue Sequel::MassAssignmentRestriction => e
          API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
          routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
        rescue StandardError => e
          puts e.full_message
          API.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: e.message }.to_json
        end

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
