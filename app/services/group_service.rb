# frozen_string_literal: true

require_relative '../models/group'
require_relative './account_service'

# CalendarCoordinator
module CalendarCoordinator
  # Group Service
  class GroupService
    include Common

    # Create Group
    def self.create(account_id:, data:)
      account = AccountService.get(id: account_id)
      raise('Account not found') unless account

      account.add_owned_group(data)
    end

    # Join Group
    def self.join(account_id:, group:)
      account = AccountService.get(id: account_id)
      raise('Account not found') unless account

      account.add_belonged_group(group)
    end

    # Get Group by id
    def self.get(id:)
      Group.find(id: id)
    end

    # Get all Group
    def self.all
      Group.all
    end

    # Update group
    def self.update(id, data)
      Group.find(id: id).update(data)
    end

    # Delete Group by id
    def self.delete(id:)
      group = get(id: id)
      group ? group.destroy : raise('Group not found')
    end

    # Add Calendar to Group
    def self.add_calendar(account_id:, calendar_id:, group_id:)
      group = get(id: group_id)
      puts "calendar_id = #{calendar_id}"
      calendar = CalendarService.get(id: calendar_id)

      calendar_current = Calendar.where(account_id: account_id).all & group.owned_calendars
      puts "calendar_current = #{calendar_current}"
      group.remove_owned_calendar(calendar_current.first) unless calendar_current.empty? || calendar_current.nil?

      puts "group = #{group}"
      puts "calendar = #{calendar}"
      group.add_owned_calendar(calendar)
    end

    # Get Owend Calendars
    def self.owned_calendars(group_id:)
      group = get(id: group_id)
      group.owned_calendars
    end

    # Get Owned Accounts
    def self.owned_accounts(group_id:)
      group = get(id: group_id)
      group.owned_accounts
    end

    # Delete account from group
    def self.delete_account(group_id, account_id)
      account = AccountService.get(id: account_id)
      raise('Account not found') unless account

      group = get(id: group_id)

      calendar = group.owned_calendars.select { |own_calendar| own_calendar.account_id == account_id }.first # rubocop:disable Performance/Detect
      calendar.remove_belonged_group(group)

      account.remove_belonged_group(group)
    end

    # Group invitation
    def self.invitation_mail(invitation_data) # rubocop:disable Metrics/MethodLength
      user_avaliable = Account.first(email: invitation_data[:email])
      raise(MailService::InvalidInviation, 'User not exists') unless user_avaliable

      group_avaliable = Group.first(id: invitation_data[:group_id])
      raise(MailService::InvalidInviation, 'Group not exists') unless group_avaliable

      html_email = <<~END_EMAIL
        <H1>ZetaCal App Group Invitation</H1>
        <p>Please <a href=\"#{invitation_data[:invitation_url]}\">click here</a>
        to join Group "#{group_avaliable.groupname}".</p>
      END_EMAIL

      mail_form = MailService.mail_form(to: invitation_data[:email],
                                        subject: 'ZetaCal Group Inviation',
                                        html: html_email)

      MailService.send(mail_form: mail_form)
    end
  end
end
