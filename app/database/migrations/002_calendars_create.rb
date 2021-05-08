# frozen_string_literal: true

require 'sequel'
require 'securerandom'

Sequel.migration do
  change do
    create_table(:calendars) do
      uuid :id, primary_key: true
      String :accounts_email, foreign_key: true, table: :accounts

      String :summary_secure, null: false
      String :description_secure
      String :location_secure
      String :time_zone
      String :access_role

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
