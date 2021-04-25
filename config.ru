# frozen_string_literal: true

require './config/environments'
require './app/controllers/app'

run CalendarCoordinator::API.freeze.app
