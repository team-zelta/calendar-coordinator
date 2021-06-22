# frozen_string_literal: true

require 'http'
require 'google/apis/oauth2_v2'

module CalendarCoordinator
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    def call(access_token, service)
      case service
      when 'github'
        account = get_github_account(access_token)
      when 'google'
        account = get_google_account(access_token)
      end

      sso_account = find_or_create_sso_account(account)

      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_response = HTTP.headers(
        user_agent: 'ZetaCal',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV['GITHUB_ACCOUNT_URL'])

      raise unless gh_response.status == 200

      account = JSON.parse(gh_response, object_class: OpenStruct)
      { username: "#{account.login}@github", email: account.email }
    end

    def get_google_account(access_token)
      response = HTTP.auth("Bearer #{access_token}")
                     .post(ENV['GOOGLE_USERINFO_URL'])

      userinfo = JSON.parse(response.body, object_class: OpenStruct)
      { username: "#{userinfo.name.delete(' ')}@google", email: userinfo.email }
    end

    def find_or_create_sso_account(account_data)
      sso_account = Account.first(email: account_data[:email]) ||
                    Account.create(username: account_data[:username],
                                   email: account_data[:email])

      if sso_account && Group.find(account_id: sso_account.id).nil?
        group_data = JSON.parse({ groupname: sso_account.username }.to_json)

        GroupService.create(account_id: sso_account.id, data: group_data)
      end

      sso_account
    end

    def account_and_token(account)
      {
        account: account,
        auth_token: AuthToken.create(account)
      }
    end
  end
end
