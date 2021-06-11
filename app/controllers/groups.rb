# frozen_string_literal: true

require 'roda'
require 'date'
require_relative './app'

module CalendarCoordinator
  # API for groups route
  class API < Roda # rubocop:disable Metrics/ClassLength
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

      # POST /api/v1/groups/invite
      routing.is 'invite' do
        routing.post do
          invitation_data = JsonRequestBody.parse_symbolize(request.body.read)

          GroupService.invitation_mail(invitation_data)
          response.status = 202
          { message: 'Invitation email sent' }.to_json
        rescue MailService::InvalidInviation => e
          puts e.full_message
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR SENDING INVIATION MAIL: #{e.inspect}"
          puts e.full_message
          routing.halt 500
        end
      end

      # POST /api/v1/groups/join
      routing.is 'join' do
        routing.post do
          data = JSON.parse(routing.body.read)

          group = GroupService.get(id: data['group_id'])
          group_join = GroupService.join(account_id: @auth_account['id'], group: group)
          if group_join
            response.status = 201
            { message: 'Group joined', group_id: group_join.id }.to_json
          else
            routing.halt 400, { message: 'Join Group failed' }.to_json
          end
        rescue Sequel::MassAssignmentRestriction => e
          API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
          routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        rescue StandardError => e
          API.logger.error "UNKOWN ERROR: #{e.full_message}"
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

            group = GroupService.get(id: group_id)

            { group: group, calendars: group_calendars }.to_json
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        routing.on 'accounts' do # rubocop:disable Metrics/BlockLength
          routing.on String do |account_id|
            # GET /api/v1/groups/{group_id}/accounts/{account_id}/delete
            routing.is 'delete' do
              routing.get do
                response.status = 200

                account = AccountService.get(id: @auth_account['id'])
                group = GroupService.get(id: group_id)

                policy = GroupPolicy.new(account, group)
                raise UnauthorizedError unless policy.can_remove_member?

                result = GroupService.delete_account(group_id, account_id)
                result.to_json
              rescue UnauthorizedError
                routing.halt 404, { message: 'Delete failed' }.to_json
              rescue StandardError => e
                puts e.full_message
                routing.halt 500, { message: e.message }.to_json
              end
            end
          end

          # GET /api/v1/groups/{group_id}/accounts
          routing.get do
            response.status = 200

            accounts = GroupService.owned_accounts(group_id: group_id)
            raise('Group owned accounts not found') unless accounts

            group = GroupService.get(id: group_id)
            owner = AccountService.get(id: group.account_id)
            raise('Group Owner not found') unless owner

            owner.username += ' (owner)'

            accounts.prepend(owner)

            accounts.to_json
          rescue StandardError => e
            puts e.full_message
            routing.halt 404, { message: e.full_message }.to_json
          end
        end

        # GET /api/v1/groups/{group_id}/delete
        routing.is 'delete' do
          routing.get do
            response.status = 200

            account = AccountService.get(id: @auth_account['id'])
            group = GroupService.get(id: group_id)
            policy = GroupPolicy.new(account, group)
            raise UnauthorizedError unless policy.can_delete?

            group_del = GroupService.delete(id: group_id)
            group_del ? group_del.to_json : raise('Group not deleted')
          rescue StandardError => e
            routing.halt 404, { message: e.full_message }.to_json
          end
        end

        routing.is 'update' do
          routing.post do
            account = AccountService.get(id: @auth_account['id'])
            group = GroupService.get(id: group_id)

            policy = GroupPolicy.new(account, group)
            raise UnauthorizedError unless policy.can_edit?

            data = JSON.parse(routing.body.read)
            group = GroupService.update(group_id, data)

            if group
              response.status = 201
              { message: 'Group updated', group_id: group_id }.to_json
            else
              routing.halt 400, { message: 'Update Group failed' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction => e
            API.logger.warn "MASS-ASSIGNMENT: #{data.keys}"
            routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
          rescue StandardError => e
            puts e.full_message
            API.logger.error "UNKOWN ERROR: #{e.full_message}"
            routing.halt 500, { message: e.full_message }.to_json
          end
        end

        # GET /api/v1/groups/{group_id}/common-busy-time/{calendar_mode}/{year}-{month}-{day}
        routing.on 'common-busy-time' do
          routing.on String do |calendar_mode|
            routing.get(String) do |date|
              response.status = 200
              group_calendars = GroupService.owned_calendars(group_id: group_id)
              group_calendars ||= raise('Group Calendars not found')

              all_events = []
              group_calendars.each do |calendar|
                events = CalendarService.owned_events_by_date(id: calendar.id, mode: calendar_mode, date: date)

                all_events += events
              end

              EventService.common_busy_time(all_events).to_json
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end
        end

        # GET /api/v1/groups/{group_id}/events/{calendar_mode}/{year}-{month}-{day}
        routing.on 'events' do
          routing.on String do |calendar_mode|
            routing.get(String) do |date|
              response.status = 200
              group_calendars = GroupService.owned_calendars(group_id: group_id)
              group_calendars ||= raise('Group Calendars not found')

              all_events = []
              group_calendars.each do |calendar|
                events = CalendarService.owned_events_by_date(id: calendar.id, mode: calendar_mode, date: date)

                account = CalendarService.belonged_accounts(id: calendar.id)

                all_events.push({ username: account.username, events: events.each(&:to_json) })
              end

              all_events.to_json
            rescue StandardError => e
              puts e.full_message
              routing.halt 404, { message: e.message }.to_json
            end
          end
        end

        # GET /api/v1/groups/{group_id}
        routing.get do
          response.status = 200

          account = AccountService.get(id: @auth_account['id'])
          group = GroupService.get(id: group_id)
          routing.halt 404, { message: 'Group not found' }.to_json unless group

          policy = GroupPolicy.new(account, group)
          raise UnauthorizedError unless policy.can_view?

          group.to_hash.merge(policies: policy.summary).to_json
        rescue UnauthorizedError
          routing.halt 404, { message: 'Group not found' }.to_json
        rescue StandardError => e
          puts e.full_message
          routing.halt 500, { message: e.message }.to_json
        end
      end

      # GET /api/v1/groups
      routing.get do
        response.status = 200

        account = AccountService.get(id: @auth_account['id'])
        groups = GroupPolicy::AccountScope.new(account).viewable

        JSON.pretty_generate(groups)
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end

      # POST /api/v1/groups
      routing.post do
        group_data = JSON.parse(routing.body.read)

        group = GroupService.create(account_id: @auth_account['id'], data: group_data)
        if group
          response.status = 201
          { message: 'Group saved', group_id: group.id }.to_json
        else
          routing.halt 400, { message: 'Save Group failed' }.to_json
        end
      rescue Sequel::MassAssignmentRestriction => e
        API.logger.warn "MASS-ASSIGNMENT: #{group_data.keys}"
        routing.halt 400, { message: "Illegal Attributes : #{e}" }.to_json
      rescue StandardError => e
        API.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
