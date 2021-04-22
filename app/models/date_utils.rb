# frozen_string_literal: true

# Common
module Common
  # DateUtils Entity
  class DateUtils
    def initialize(time)
      @date = time['date']
      @date_time = time['date_time']
      @time_zone = time['time_zone']
    end

    attr_reader :date, :date_time, :time_zone

    def to_json(options = {})
      JSON(
        {
          date: date,
          date_time: date_time,
          time_zone: time_zone
        },
        options
      )
    end
  end
end
