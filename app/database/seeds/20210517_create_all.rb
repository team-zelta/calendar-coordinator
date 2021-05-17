# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, groups, calenders, events'
    create_accounts
    create_owned_calendars
    create_owned_groups
    add_belonged_groups
    add_calendar_evnets
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_CALENDAR_INFO = YAML.load_file("#{DIR}/owners_calendars.yml")
OWNER_GROUP_INFO = YAML.load_file("#{DIR}/owners_groups.yml")
MEMBER_GROUP_INFO = YAML.load_file("#{DIR}/members_groups.yml")
CALENDAR_INFO = YAML.load_file("#{DIR}/calendars_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    CalendarCoordinator::Account.create(account_info)
  end
end

def create_owned_calendars
  OWNER_CALENDAR_INFO.each do |owner|
    account = CalendarCoordinator::Account.first(username: owner['username'])
    owner['summary'].each do |summary|
      calendar_data = CALENDAR_INFO.find { |calendar| calendar['summary'] == summary }
      CalendarCoordinator::CalendarService.create(
        account_id: account.id, data: calendar_data
      )
    end
  end
end

def create_owned_groups
  OWNER_GROUP_INFO.each do |owner_group_info|
    account = CalendarCoordinator::Account.first(email: owner_group_info['email'])
    owner_group_info['groups'].each do |group|
      CalendarCoordinator::GroupService.create(account_id: account.id, data: group)
    end
  end
end

def add_belonged_groups
  MEMBER_GROUP_INFO.each do |member_group_info|
    account = CalendarCoordinator::Account.first(email: member_group_info['email'])
    group = CalendarCoordinator::Group.first(groupname: member_group_info['group_name'])
    account.add_belonged_group(group)
  end
end

# Now only add evnets to calendar 1
def add_calendar_evnets
  EVENT_INFO.each do |event_info|
    calendar = CalendarCoordinator::Calendar.first
    CalendarCoordinator::EventService.create(calendar_id: calendar.id, data: event_info)
  end
end
