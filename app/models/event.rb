# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

require_relative 'date_utils'

# Calendar
module Calendar
  STORE_DIR = 'app/database/store'

  # Event Entity
  class Event
    def initialize(event)
      @id = event['id'] || new_id
      @status = event['status']
      @summary = event['summary']
      @description = event['description']
      @location = event['location']
      @start_time = DateUtils.new(event['start'])
      @end_time = DateUtils.new(event['end'])
    end

    attr_reader :id, :status, :summary, :description, :location, :start_time, :end_time

    def to_json(options = {})
      JSON(
        {
          id: id,
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

    # Setup store directory
    def self.setup
      Dir.mkdir(Calendar::STORE_DIR) unless Dir.exist? Calendar::STORE_DIR
    end

    # Save Event
    def save
      File.write("#{Calendar::STORE_DIR}/#{id}.txt", to_json)
    end

    # Find Event by id
    def self.find(id)
      event = File.read("#{Calendar::STORE_DIR}/#{id}.txt")
      Event.new(JSON.parse(event))
    end

    # Find all Event
    def self.all
      Dir.glob("#{Calendar::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Calendar::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    # Create new id
    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
