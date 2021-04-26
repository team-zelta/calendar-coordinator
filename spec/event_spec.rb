# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../config/environments'
require_relative '../app/controllers/app'
require_relative '../app/models/event'
require_relative 'spec_helper'

describe 'Test CalendarCoordinator Web API - event' do
  include Rack::Test::Methods

  # Create database and import test data
  def create_database
    DATA[:calendars].each do |calendar|
      CalendarCoordinator::Calendar.create(calendar).save
    end

    calendar = CalendarCoordinator::Calendar.first
    DATA[:events].each do |event|
      calendar.add_event(event)
    end
  end

  before do
    wipe_database
    create_database
  end

  # Get all events
  it 'HAPPY: should be able to get list of all events' do
    calendar_id = 'sample1@gmail.com'

    get "api/v1/calendars/#{calendar_id}/events"

    result = JSON.parse(last_response.body)
    _(result.count).must_equal 2
  end

  # Get event by id
  it 'HAPPY: should be able to get event by id' do
    calendar_id = 'sample1@gmail.com'
    event_id = 'abc001'

    get "api/v1/calendars/#{calendar_id}/events/#{event_id}"

    result = JSON.parse(last_response.body)
    _(result['id']).must_equal 'abc001'
  end

  it 'SAD: should not be able to get event by id due to event not exist' do
    calendar_id = 'sample1@gmail.com'
    event_id = 'abc000'

    get "api/v1/calendars/#{calendar_id}/events/#{event_id}"

    result = JSON.parse(last_response.body)
    _(result['message']).must_equal 'Event not found'
  end

  it 'SAD: should return error if unknown event requested' do
    calendar_id = 'sample1@gmail.com'

    get "api/v1/calendars/#{calendar_id}/events/foo"

    _(last_response.status).must_equal 404
  end

  # Create Event
  it 'HAPPY: should be able to create event' do
    calendar_id = 'sample1@gmail.com'

    event = CalendarCoordinator::Event.new(id: 'abc000',
                                           summary: 'Poject Meeting')

    req_header = { 'Content-Type' => 'application/json' }
    post "api/v1/calendars/#{calendar_id}/events", event.to_json, req_header

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 201
    _(result['message']).must_equal 'Event saved'
  end

  it 'SAD: should not be able to create event due to existed event' do
    calendar_id = 'sample1@gmail.com'

    event = CalendarCoordinator::Event.new(id: 'abc001',
                                           summary: 'Project Meeting')

    req_header = { 'Content-Type' => 'application/json' }
    post "api/v1/calendars/#{calendar_id}/events", event.to_json, req_header

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 200
    _(result['message']).must_equal 'Event existed'
  end
end
