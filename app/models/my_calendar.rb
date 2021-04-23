# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

# Calendar
module Calendar
  # Calendar Class
  class MyCalendar
    STORE_DIR = 'app/database/store/calendars'

    def initialize(calendar)
      @id = calendar['id'] || new_id
      @summary = calendar['summary']
      @description = calendar['description']
      @location = calendar['location']
      @time_zone = calendar['timeZone']
      @access_role = calendar['accessRole']
    end

    attr_reader :id, :summary, :description, :location, :time_zone, :access_role

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          id: id,
          summary: summary,
          description: description,
          location: location,
          time_zone: time_zone,
          access_role: access_role
        },
        options
      )
    end

    # Setup store directory
    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    # Save Calendar
    def save
      File.write("#{STORE_DIR}/#{id}.txt", to_json)
    end

    # Find Calendar by id
    def self.find(id)
      calendar = File.read("#{STORE_DIR}/#{id}.txt")
      MyCalendar.new(JSON.parse(calendar))
    end

    # Find all Calendars
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
