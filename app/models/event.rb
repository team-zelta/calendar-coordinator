# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

# CalendarCoordinator
module CalendarCoordinator
  STORE_DIR = 'app/database/store/events'

  # Event Entity
  class Event
    # rubocop:disable Metrics/MethodLength
    def initialize(event)
      @id = event['id'] || new_id
      @status = event['status']
      @summary = event['summary']
      @description = event['description']
      @location = event['location']
      @start_date = event['start_date']
      @start_date_time = event['start_date_time']
      @start_time_zone = event['start_time_zone']
      @end_date = event['end_date']
      @end_date_time = event['end_date_time']
      @end_time_zone = event['end_time_zone']
    end

    attr_reader :id, :status, :summary, :description, :location,
                :start_date, :start_date_time, :start_time_zone,
                :end_date, :end_date_time, :end_time_zone

    def to_json(options = {})
      JSON(
        {
          id: id,
          status: status,
          summary: summary,
          description: description,
          location: location,
          start_date: start_date,
          start_date_time: start_date_time,
          start_time_zone: start_time_zone,
          end_date: end_date,
          end_date_time: end_date_time,
          end_time_zone: end_time_zone
        },
        options
      )
    end
    # rubocop:enable Metrics/MethodLength

    # Setup store directory
    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    # Save Event
    def save
      File.write("#{STORE_DIR}/#{id}.txt", to_json)
    end

    # Find Event by id
    def self.find(id)
      event = File.read("#{STORE_DIR}/#{id}.txt")
      Event.new(JSON.parse(event))
    end

    # Find all Event
    def self.all
      Dir.glob("#{STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(STORE_DIR)}/(.*)\.txt})[1]
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
