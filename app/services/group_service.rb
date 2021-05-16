# frozen_string_literal: true

require_relative '../models/group'
require_relative './account_service'

# CalendarCoordinator
module CalendarCoordinator
  # Group Service
  class GroupService
    # Create Group
    def self.create(account_id:, data:)
      account = AccountService.get(id: account_id)
      raise('Account not found') unless account

      account.add_belonged_group(data)
    end

    # Get Group by id
    def self.get(id:)
      Group.find(id: id)
    end

    # Get all Group
    def self.all
      Group.all
    end

    # Delete Group by id
    def self.delete(id:)
      group = get(id: id)
      puts group
      group ? group.destroy : raise('Group not found')
    end
  end
end
