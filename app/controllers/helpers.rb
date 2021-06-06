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
      account_payload = AuthToken.payload(auth_token)
      scheme.match?(/^Bearer$/i) ? account_payload : nil
    end
  end
end
