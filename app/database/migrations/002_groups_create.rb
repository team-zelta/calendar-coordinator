# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      uuid :id, primary_key: true
      uuid :account_id, foreign_key: true, table: :accounts

      String :groupname, null: false, unique: true
      String :password_digest

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
