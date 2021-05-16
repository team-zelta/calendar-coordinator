# frozen_string_literal: true

require 'roda'
require_relative './app'

module CalendarCoordinator
  # API for groups route
  class API < Roda
    route('groups') do |routing|
      routing.on String do |group_id|
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
        puts '12342343'
        response.status = 200
        JSON.pretty_generate(GroupService.all)
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
