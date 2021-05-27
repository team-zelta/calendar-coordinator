# frozen_string_literal: true

require 'roda'
require_relative './app'

module CalendarCoordinator
  # API for groups route
  class API < Roda
    route('groups') do |routing| # rubocop:disable Metrics/BlockLength
      # POST /api/v1/groups/add-calendar
      routing.is 'add-calendar' do
        routing.post do
          data = JSON.parse(routing.body.read)
          calendar = GroupService.add_calendar(calendar_id: data['calendar_id'], group_id: data['group_id'])
          if calendar
            response.status = 201
            { message: 'Add calendar to group success', calendar_id: calendar.id }.to_json
          else
            routing.halt 400, { message: 'Add calendar to group failed' }.to_json
          end
        rescue Sequel::MassAssignmentRestriction => e
          API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
          routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
        rescue StandardError => e
          API.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: e.message }.to_json
        end
      end

      routing.on String do |group_id| # rubocop:disable Metrics/BlockLength
        # GET /api/v1/groups/{group_id}/calendars
        routing.is 'calendars' do
          routing.get do
            response.status = 200
            group_calendars = GroupService.owned_calendars(group_id: group_id)
            group_calendars ? group_calendars.to_json : raise('Group Calendars not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        # GET /api/v1/groups/{group_id}/common-busy-time
        routing.is 'common-busy-time' do
          routing.get do
            response.status = 200
            group_calendars = GroupService.owned_calendars(group_id: group_id)
            group_calendars ||= raise('Group Calendars not found')

            all_events = []
            group_calendars.each do |calendar|
              events = CalendarService.owned_events(id: calendar.id)
              all_events += events
            end

            EventService.common_busy_time(all_events).to_json
          end
        end

        # GET /api/v1/groups/{group_id}/delete
        routing.is 'delete' do
          routing.get do
            response.status = 200
            group = GroupService.delete(id: group_id)
            group ? group.to_json : raise('Group not deleted')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        # GET /api/v1/groups/{group_id}
        routing.get do
          response.status = 200
          group = GroupService.get(id: group_id)
          group ? group.to_json : raise('Group not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET /api/v1/groups
      routing.get do
        response.status = 200
        JSON.pretty_generate(GroupService.all)
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
