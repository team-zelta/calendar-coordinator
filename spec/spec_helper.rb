# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

def app
  CalendarCoordinator::API
end

# Delete database
def wipe_database
  app.DB[:events].delete
  app.DB[:calendars].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:events] = YAML.safe_load(File.read('app/database/seeds/event_seeds.yml'))
DATA[:calendars] = YAML.safe_load(File.read('app/database/seeds/calendar_seeds.yml'))
