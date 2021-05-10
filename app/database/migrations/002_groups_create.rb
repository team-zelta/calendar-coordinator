# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      uuid :id, primary_key: true

      String :groupname, null: false
      String :password_digest

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
