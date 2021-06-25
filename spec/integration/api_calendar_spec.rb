# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test CalendarCoordinator Web API - calendar' do
  include Rack::Test::Methods

  # Create database and import test data
  def create_database # rubocop:disable Metrics/MethodLength
    DATA[:accounts].each do |account|
      CalendarCoordinator::AccountService.create(data: account).save
    end

    DATA[:owners_calendars].each do |owner|
      account = CalendarCoordinator::Account.first(username: owner['username'])
      owner['summary'].each do |summary|
        calendar_data = DATA[:calendars].find { |calendar| calendar['summary'] == summary }
        CalendarCoordinator::CalendarService.create(
          account_id: account.id, calendars: [calendar_data]
        )
      end
    end
  end

  before do
    wipe_database
    create_database
  end

  # Get all calendars
  it 'HAPPY: should get list for authorized account' do
    auth = CalendarCoordinator::AccountService.authenticate(
      username: DATA[:accounts][0]['username'],
      password: DATA[:accounts][0]['password']
    )
    header 'AUTHORIZATION', "Bearer #{auth[:auth_token]}"
    get 'api/v1/calendars'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 1
  end

  it 'BAD: should not process for unauthorized account' do
    header 'AUTHORIZATION', 'Bearer bad_token'
    get 'api/v1/calendars'
    _(last_response.status).must_equal 403

    result = JSON.parse last_response.body
    _(result['data']).must_be_nil
  end

  # Get calendar by id
  it 'HAPPY: should be able to get calendar by id' do
    id = CalendarCoordinator::Calendar.first.id
    get "api/v1/calendars/#{id}"

    result = JSON.parse(last_response.body)
    _(result['summary']).must_equal 'Tony Calendar'
  end

  it 'SAD: should not be able to get calendar if unknown calendar requested' do
    get 'api/v1/calendars/foobar'

    result = JSON.parse(last_response.body)
    _(result['message']).must_equal 'Calendar not found'
  end

  it 'SECURITY SQL INJECTION: should prevent basic SQL injection targeting IDs' do
    get 'api/v1/calendars/2%20or%20id%3E0'

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end

  # Create calendar
  it 'HAPPY: should be able to create calendar' do
    sample_calendar = DATA[:calendars][1]
    account = CalendarCoordinator::Account.first

    req_header = { 'Content-Type' => 'application/json' }
    post "api/v1/accounts/#{account.id}/calendars", [sample_calendar].to_json, req_header

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 201
    _(result['message']).must_equal 'Calendar saved'
  end

  it 'SECURITY MASS ASSIGNMENT: should not be able to create calendar by mass assignment' do
    sample_calendar = DATA[:calendars][1].clone
    sample_calendar['id'] = '00000000-0000-0000-0000-000000000000'
    sample_calendar['gid'] = 'abc001'

    account = CalendarCoordinator::Account.first

    req_header = { 'Content-Type' => 'application/json' }
    post "api/v1/accounts/#{account.id}/calendars", [sample_calendar].to_json, req_header

    _(last_response.status).must_equal 400
  end
end
