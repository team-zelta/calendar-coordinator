# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

# Delete database
def wipe_database
  app.DB[:events].delete
  app.DB[:calendars].delete
  app.DB[:accounts].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:events] = YAML.safe_load(File.read('app/database/seeds/event_seeds.yml'))
DATA[:calendars] = YAML.safe_load(File.read('app/database/seeds/calendar_seeds.yml'))
DATA[:accounts] = YAML.safe_load(File.read('app/database/seeds/account_seeds.yml'))
