# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/event'

def app
  CalendarCoordinator::API
end

DATA = YAML.safe_load(File.read('app/database/seeds/event_seeds.yml'))
STORE_DIR = 'app/database/store/event'

describe 'Test CalendarCoordinator Web API - event' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  # Get all events id
  it 'should be able to get list of all events id' do
    CalendarCoordinator::Event.new(DATA[0]).save
    CalendarCoordinator::Event.new(DATA[1]).save

    get 'api/v1/events'
    result = JSON.parse(last_response.body)

    _(result.count).must_equal 2
  end

  # Get event by id
  it 'should be able to get event by id' do
    CalendarCoordinator::Event.new(DATA[0]).save
    id = 1001

    get "api/v1/events/#{id}"
    result = JSON.parse(last_response.body)

    _(result['id']).must_equal 1001
  end

  it 'should return error if unknown event requested' do
    get 'api/v1/events/foo'

    _(last_response.status).must_equal 404
  end

  # Create Event
  it 'should be able to create event' do
    req_header = { 'Content-Type' => 'application/json' }
    post 'api/v1/events', DATA[0].to_json, req_header

    _(last_response.status).must_equal 201
  end
end
