# frozen_string_literal: true

require_relative '../models/account'

# CalendarCoordinator
module CalendarCoordinator
  # Account Service
  class AccountService
    # Create Account
    def self.create(data:)
      Account.create(data)
    end

    # Get Account by id
    def self.get(id:)
      Account.find(id: id)
    end

    # Get all Account
    def self.all
      Account.all
    end
  end
end
