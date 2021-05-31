# frozen_string_literal: true

require 'roda'
require 'json'

# Calendar
module CalendarCoordinator
  # WebAPI controller
  class API < Roda
    plugin :halt
    plugin :multi_route

    def secure_request?(routing)
      routing.scheme.casecmp(ENV['SECURE_SCHEME']).zero?
    end

    route do |routing|
      response['Content-Type'] = 'application/json'
      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      routing.root do
        response.status = 200
        { message: 'Calendar API up at /api/v1' }.to_json
      end

      @api_v1 = 'api/v1'
      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
