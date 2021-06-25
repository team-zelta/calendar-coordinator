# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'simplecov'

require_relative 'test_load_all'

SimpleCov.start

# Delete database
def wipe_database
  app.DB[:events].delete
  app.DB[:calendars].delete
  app.DB[:groups].delete
  app.DB[:accounts].delete
end

def auth_header(account_data)
  auth = CalendarCoordinator::AccountService.authenticate(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:auth_token]}"
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load(File.read('app/database/seeds/accounts_seed.yml'))
DATA[:calendars] = YAML.safe_load(File.read('app/database/seeds/calendars_seed.yml'))
DATA[:owners_calendars] = YAML.safe_load(File.read('app/database/seeds/owners_calendars.yml'))
DATA[:events] = YAML.safe_load(File.read('app/database/seeds/events_seed.yml'))
DATA[:owners_groups] = YAML.safe_load(File.read('app/database/seeds/owners_groups.yml'))
