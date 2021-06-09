# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test CalendarCoordinator Web API - group' do
  include Rack::Test::Methods

  # Create database and import test data
  def create_database
    DATA[:accounts].each do |account|
      CalendarCoordinator::AccountService.create(data: account)
    end

    DATA[:owners_groups].each do |owner|
      account = CalendarCoordinator::Account.first(email: owner['email'])
      owner['groups'].each do |group|
        CalendarCoordinator::GroupService.create(account_id: account.id, data: group)
      end
    end
  end

  before do
    wipe_database
  end

  # Get all groups
  it 'HAPPY: should be able to get list of all groups' do
    create_database

    account = DATA[:accounts].clone[0]

    header 'AUTHORIZATION', auth_header(account)
    get 'api/v1/groups'

    result = JSON.parse(last_response.body)
    _(result.count).must_equal 1
  end

  # Get group by id
  it 'HAPPY: should be able to get group by id' do
    create_database
    group_id = CalendarCoordinator::Group.first.id

    get "api/v1/groups/#{group_id}"

    result = JSON.parse(last_response.body)
    _(result['groupname']).must_equal 'group1'
  end

  it 'SAD: should not be able to get group by id due to group not exist' do
    create_database
    group_id = '00000000-0000-0000-0000-000000000000'
    get "api/v1/groups/#{group_id}"

    result = JSON.parse(last_response.body)
    _(result['message']).must_equal 'Group not found'
  end

  it 'SAD: should return error if unknown group requested' do
    create_database
    get 'api/v1/groups/foo'

    _(last_response.status).must_equal 404
  end

  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    create_database
    get 'api/v1/groups/2%20or%20id%3E0'

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end

  # Create group
  it 'HAPPY: should be able to create group' do
    DATA[:accounts].each do |account|
      CalendarCoordinator::AccountService.create(data: account)
    end
    account = DATA[:accounts].clone[0]

    group = DATA[:owners_groups].clone[0]['groups'][0]

    header 'AUTHORIZATION', auth_header(account)
    post 'api/v1/groups', group.to_json

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 201
    _(result['message']).must_equal 'Group saved'
  end

  it 'SECURITY: should not be able to create group with mass assignment' do
    DATA[:accounts].each do |account|
      CalendarCoordinator::AccountService.create(data: account)
    end
    account = DATA[:accounts].clone[0]
    cloned_group = DATA[:owners_groups][0]['groups'][0].clone
    cloned_group['id'] = '00000000-0000-0000-0000-000000000000'

    header 'AUTHORIZATION', auth_header(account)
    req_header = { 'Content-Type' => 'application/json' }
    post 'api/v1/groups', cloned_group.to_json, req_header

    _(last_response.status).must_equal 400
  end
end
