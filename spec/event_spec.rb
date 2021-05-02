# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../require_app'
require_relative 'spec_helper'

require_app

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
    calendar_id = CalendarCoordinator::Calendar.first.id

    get "api/v1/calendars/#{calendar_id}/events"

    result = JSON.parse(last_response.body)
    _(result.count).must_equal 2
  end

  # Get event by id
  it 'HAPPY: should be able to get event by id' do
    calendar_id = CalendarCoordinator::Calendar.first.id
    event_id = CalendarCoordinator::Event.first.id

    get "api/v1/calendars/#{calendar_id}/events/#{event_id}"

    result = JSON.parse(last_response.body)
    _(result['gid']).must_equal 'abc001'
  end

  it 'SAD: should not be able to get event by id due to event not exist' do
    calendar_id = CalendarCoordinator::Calendar.first.id
    event_id = '00000000-0000-0000-0000-000000000000'

    get "api/v1/calendars/#{calendar_id}/events/#{event_id}"

    result = JSON.parse(last_response.body)
    _(result['message']).must_equal 'Event not found'
  end

  it 'SAD: should return error if unknown event requested' do
    calendar_id = CalendarCoordinator::Calendar.first.id

    get "api/v1/calendars/#{calendar_id}/events/foo"

    _(last_response.status).must_equal 404
  end

  # Create Event
  it 'HAPPY: should be able to create event' do
    calendar_id = CalendarCoordinator::Calendar.first.id

    event = CalendarCoordinator::Event.new(summary: 'Project Meeting')

    req_header = { 'Content-Type' => 'application/json' }
    post "api/v1/calendars/#{calendar_id}/events", event.to_json, req_header

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 201
    _(result['message']).must_equal 'Event saved'
  end
end
