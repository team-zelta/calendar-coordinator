# frozen_string_literal: true

module CalendarCoordinator
  # Methods for controllers to mixin
  module SecureRequestHelpers
    def secure_request?(routing)
      routing.scheme.casecmp(ENV['SECURE_SCHEME']).zero?
    end

    def authenticated_account(headers)
      return nil unless headers['AUTHORIZATION']

      scheme, auth_token = headers['AUTHORIZATION'].split
      return nil unless scheme.match?(/^Bearer$/i)

      puts auth_token

      contents = AuthToken.contents(auth_token)
      puts contents

      {
        account: Account.first(id: contents['payload']['id']),
        scope: AuthScope.new(contents['scope'])
      }
    end
  end
end
