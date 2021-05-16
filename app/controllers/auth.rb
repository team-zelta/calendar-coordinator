# frozen_string_literal: true

module CalendarCoordinator
  # API for accounts route
  class API < Roda
    include Common

    route('auth') do |routing|
      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          data = request.body.read
          credentials = JsonRequestBody.parse_symbolize(data)
          auth_account = AccountService.authenticate(credentials)
          auth_account.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
