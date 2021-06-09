# frozen_string_literal: true

module CalendarCoordinator
  # Policy to determine if an account can manage the group
  class GroupPolicy
    def initialize(account, group)
      @account = account
      @group = group
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_member?
    end

    def can_remove_member?
      account_is_owner?
    end

    def summary
      {
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_remove_member: can_remove_member?
      }
    end

    private

    def account_is_owner?
      @group.account_id == @account.id
    end

    def account_is_member?
      members = GroupService.owned_accounts(@group.id)
      members.include?(@account)
    end
  end
end