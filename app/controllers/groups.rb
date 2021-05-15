# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative '../services/group_service'

module CalendarCoordinator
  # API for groups route
  class API < Roda
    route('groups') do |routing|
      routing.get String do |group_id|
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
