# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test CalendarCoordinator Web API - root' do
  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end
end
