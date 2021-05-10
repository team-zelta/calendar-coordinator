# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

# CalendarCoordinator
module CalendarCoordinator
  # Group Class
  class Group < Sequel::Model
    one_to_many :owned_accounts, class: :'CalendarCoordinator::Account',
                                 key: :account_id
    many_to_many :accounts, class: :'CalendarCoordinator::Account',
                            join_table: :groups_accounts,
                            left_key: :group_id, right_key: :account_id

    plugin :association_dependencies
    add_association_dependencies accounts: :nullify

    # Auto set created_at & updated_at
    plugin :timestamps, update_on_create: true

    plugin :uuid, field: :id
    plugin :whitelist_security

    set_allowed_columns :groupname, :password

    def accounts
      owned_accounts
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = CalendarCoordinator::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          id: id,
          groupname: groupname
        },
        options
      )
    end
  end
end
