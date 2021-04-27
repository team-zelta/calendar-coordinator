# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../require_app'
require_app

def app
  CalendarCoordinator::API
end

describe 'Test CalendarCoordinator Web API - root' do
  include Rack::Test::Methods

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end
end
