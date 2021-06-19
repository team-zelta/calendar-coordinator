# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers'

# Calendar
module CalendarCoordinator
  # WebAPI controller
  class API < Roda
    plugin :halt
    plugin :multi_route
    plugin :request_headers

    include SecureRequestHelpers

    route do |routing|
      response['Content-Type'] = 'application/json'
      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth = authenticated_account(routing.headers)
        @auth_account = @auth[:account] if @auth
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      end

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
