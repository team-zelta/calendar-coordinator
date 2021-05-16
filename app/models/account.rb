# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

# CalendarCoordinator
module CalendarCoordinator
  # Account Class
  class Account < Sequel::Model
    one_to_many :owned_calendars, class: :'CalendarCoordinator::Calendar',
                                  key: :account_id

    many_to_many :belonged_groups,
                 class: :'CalendarCoordinator::Group',
                 join_table: :accounts_groups,
                 left_key: :account_id, right_key: :group_id

    plugin :association_dependencies, owned_calendars: :destroy,
                                      belonged_groups: :nullify

    # Auto set created_at & updated_at
    plugin :timestamps, update_on_create: true

    plugin :uuid, field: :id
    plugin :whitelist_security

    set_allowed_columns :username, :email, :password

    def calendars
      owned_calendars
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
          username: username,
          email: email
        },
        options
      )
    end
  end
end
