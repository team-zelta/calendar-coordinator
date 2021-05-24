# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(group_id: { table: :groups, type: :uuid }, calendar_id: { table: :calendars, type: :uuid })
  end
end
