# frozen_string_literal: true

# Common
module Common
  # DateTime Entity
  class DateTime
    def initialize(_time)
      @date = event['date']
      @date_time = event['date_time']
      @time_zone = event['time_zone']
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
