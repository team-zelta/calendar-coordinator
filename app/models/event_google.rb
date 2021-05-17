# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

require_relative 'date_utils'

# GoogleCalendar
module GoogleCalendar
  # Event for Google API
  class EventGoogle
    include Common

    def initialize(event)
      @gid = event['id'] || new_id
      @status = event['status']
      @summary = event['summary']
      @description = event['description']
      @location = event['location']
      @start_time = DateUtils.new(event['start'])
      @end_time = DateUtils.new(event['end'])
    end

    attr_reader :gid, :status, :summary, :description, :location, :start_time, :end_time

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          gid: gid,
          status: status,
          summary: summary,
          description: description,
          location: location,
          start: start_time,
          end: end_time
        },
        options
      )
    end

    # Get event list from google
    def self.list
      'Not Implement'
    end
  end
end
