# frozen_string_literal: true

require 'roda'
require_relative './app'

module CalendarCoordinator
  # API for accounts route
  class API < Roda
    route('accounts') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on String do |account_id| # rubocop:disable Metrics/BlockLength
        routing.on 'calendars' do
          # POST /api/v1/accounts/{account_id}/calendars
          routing.post do
            data = JSON.parse(routing.body.read)
            calendar = CalendarService.create(account_id: account_id, calendars: data)
            if calendar
              response.status = 201
              { message: 'Calendar saved' }.to_json
            else
              routing.halt 400, { message: 'Save Calendar failed' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction => e
            API.logger.warn "MASS-ASSIGNMENT: #{data[0].keys}"
            routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
          rescue StandardError => e
            API.logger.error "UNKOWN ERROR: #{e.full_message}"
            routing.halt 500, { message: e.message }.to_json
          end
        end

        # GET /api/v1/accounts/{account_id}/delete
        routing.is 'delete' do
          routing.get do
            response.status = 200
            account = AccountService.delete(id: account_id)
            account ? account.to_json : raise('Account not deleted')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        # GET /api/v1/accounts/{account_id}
        routing.get do
          response.status = 200
          account = AccountService.get(id: account_id)
          raise('Account not found') unless account

          {
            account: account,
            auth_token: AuthToken.create(account, AuthScope.new(AuthScope::READ_ONLY))
          }.to_json
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
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
        @request_data = SignedRequest.new.parse(request.body.read)
        # data = JSON.parse(routing.body.read)
        account = AccountService.create(data: @request_data)
        if account
          group_data = JSON.parse({ groupname: account.email }.to_json)

          group = GroupService.create(account_id: account.id, data: group_data)
          if group
            response.status = 201
            { message: 'Account saved', account_id: account.id }.to_json
          end
        else
          routing.halt 400, { message: 'Save Account failed' }.to_json
        end
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
