# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'

def app
  Calendar::API
end

describe 'Test Calendar Web API - root' do
  include Rack::Test::Methods

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end
end
