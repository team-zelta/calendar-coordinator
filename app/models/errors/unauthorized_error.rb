# frozen_string_literal: true

module Common
  # UnauthorizedError
  class UnauthorizedError < StandardError
    def initialize(msg = nil) # rubocop:disable Lint/MissingSuper
      @credentials = msg
    end

    def message
      "Invalid Credentials for: #{@credentials[:username]}"
    end
  end
end
