# frozen_string_literal: true

require 'sequel'
require 'securerandom'

Sequel.migration do
  change do
    create_table(:calendars) do
      uuid :id, primary_key: true

      String :email, null: false
      String :summary, null: false
      String :description
      String :location
      String :time_zone
      String :access_role

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
