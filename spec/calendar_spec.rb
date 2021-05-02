# frozen_string_literal: true

require_relative '../require_app'
require_relative 'spec_helper'

require_app

describe 'Test CalendarCoordinator Web API - calendar' do
  include Rack::Test::Methods

  # Create database and import test data
  def create_database
    DATA[:calendars].each do |calendar|
      CalendarCoordinator::Calendar.create(calendar).save
    end
  end

  before do
    wipe_database
    create_database
  end

  # Get all calendars
  it 'HAPPY: should be able to get list of all calendars' do
    get 'api/v1/calendars'

    result = JSON.parse(last_response.body)
    _(result.count).must_equal 2
  end

  # Get calendar by id
  it 'HAPPY: should be able to get calendar by id' do
    id = CalendarCoordinator::Calendar.first.id

    get "api/v1/calendars/#{id}"

    result = JSON.parse(last_response.body)
    _(result['summary']).must_equal 'Project Meeting'
  end

  it 'SAD: should not be able to get calendar if unknown calendar requested' do
    get 'api/v1/calendars/foobar'

    result = JSON.parse(last_response.body)
    _(result['message']).must_equal 'Calendar not found'
  end

  # Create calendar
  it 'HAPPY: should be able to create calendar' do
    sample_calendar = DATA[:calendars][1]

    req_header = { 'Content-Type' => 'application/json' }
    post 'api/v1/calendars', sample_calendar.to_json, req_header

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 201
    _(result['message']).must_equal 'Calendar saved'
  end

  it 'SECURITY: should not be able to create calendar by mass assignment' do
    sample_calendar = DATA[:calendars][1].clone
    sample_calendar['id'] = '00000000-0000-0000-0000-000000000000'

    req_header = { 'Content-Type' => 'application/json' }
    post 'api/v1/calendars', sample_calendar.to_json, req_header

    _(last_response.status).must_equal 400
  end

  ## Wait for User model

  # it 'SAD: should not be able to create calendar due to existed calendar under the same account' do
  #   calendar_id = 'sample1@gmail.com'

  #   event = CalendarCoordinator::Event.new(id: 'abc001',
  #                                          summary: 'Project Meeting')

  #   req_header = { 'Content-Type' => 'application/json' }
  #   post "api/v1/calendars/#{calendar_id}/events", event.to_json, req_header

  #   result = JSON.parse(last_response.body)
  #   _(last_response.status).must_equal 200
  #   _(result['message']).must_equal 'Event existed'
  # end
end
