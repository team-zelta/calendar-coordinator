# frozen_string_literal: true

module CalendarCoordinator
  # Policy to determine if an account can manage the group
  class GroupPolicy
    # Scope of Group policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_groups(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |group|
            includes_members?(group, @current_account)
          end
        end
      end

      private

      def all_groups(account)
        account.owned_groups + account.belonged_groups
      end

      def includes_members?(group, account)
        group.owned_accounts.include? account
      end
    end
  end
end
