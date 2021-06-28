# frozen_string_literal: true

require 'roda'
require_relative './app'

module CalendarCoordinator
  # API for accounts route
  class API < Roda
    include Common

    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new.parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          # data = request.body.read
          # credentials = JsonRequestBody.parse_symbolize(data)
          auth_account = AccountService.authenticate(@request_data)
          auth_account.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end

      routing.is 'register' do
        # POST /api/v1/auth/register
        routing.post do
          # regisration_data = JsonRequestBody.parse_symbolize(request.body.read)

          AccountService.register_verification(@request_data)
          response.status = 202
          { message: 'Verfication email sent' }.to_json
        rescue MailService::InvalidRegistration => e
          puts e.full_message
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          puts e.full_message
          routing.halt 500
        end
      end

      routing.on 'sso' do
        # POST /auth/sso/{service}, service: google, github
        routing.post String do |service|
          # auth_request = JsonRequestBody.parse_symbolize(request.body.read)

          auth_account = AuthorizeSso.new.call(@request_data[:access_token], service)
          { data: auth_account }.to_json
        rescue StandardError => e
          puts "FAILED to validate Github account: #{e.inspect}"
          puts e.backtrace
          routing.halt 400
        end
      end
    end
  end
end
