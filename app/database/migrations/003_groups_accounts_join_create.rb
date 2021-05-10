# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(group_id: :groups, account_id: :accounts)
  end
end
