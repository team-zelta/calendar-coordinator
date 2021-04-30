# frozen_string_literal: true

require 'sequel'
require 'securerandom'

Sequel.migration do
  change do
    create_table(:events) do
      uuid :id, primary_key: true
      foreign_key :calendar_id, table: :calendars

      String :gid
      String :status
      String :summary, null: false
      String :description
      String :location

      DateTime :start_date
      DateTime :start_date_time
      String :start_time_zone

      DateTime :end_date
      DateTime :end_date_time
      String :end_time_zone

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
