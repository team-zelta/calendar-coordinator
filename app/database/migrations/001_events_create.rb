# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id

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
