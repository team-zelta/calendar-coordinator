# frozen_string_literal: true

require_relative '../models/account'

# CalendarCoordinator
module CalendarCoordinator
  # Account Service
  class AccountService
    include Common

    # Error for invalid credentials
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        super
        @credentials = msg
      end

      def message
        "Invalid Credentials for: #{@credentials[:username]}"
      end
    end

    # Create Account
    def self.create(data:)
      Account.create(data)
    end

    # Get Account by id
    def self.get(id:)
      Account.find(id: id)
    end

    # Get all Account
    def self.all
      Account.all
    end

    # Delete Account by id
    def self.delete(id:)
      account = get(id: id)
      account ? account.destroy : raise('Account not found')
    end

    # Authenticate account
    def self.authenticate(credentials) # rubocop:disable Metrics/MethodLength
      account = Account.first(username: credentials[:username])
      account.password?(credentials[:password]) ? account : raise(UnauthorizedError, credentials)

      {
        type: 'authenticated_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    rescue StandardError
      raise(UnauthorizedError, credentials)
    end

    # Account registration verify
    def self.register_verification(registration) # rubocop:disable Metrics/MethodLength
      user_avaliable = Account.first(username: registration[:username]).nil?
      raise(MailService::InvalidRegistration, 'Username exists') unless user_avaliable

      email_avaliable = Account.first(email: registration[:email]).nil?
      raise(MailService::InvalidRegistration, 'Email exists') unless email_avaliable

      html_email = <<~END_EMAIL
        <H1>ZetaCal App Registration Received</H1>
        <p>Please <a href=\"#{registration[:verification_url]}\">click here</a>
        to validate your email.
        You will be asked to set a password to activate your account.</p>
      END_EMAIL

      mail_form = MailService.mail_form(to: registration[:email],
                                        subject: 'ZetaCal Registration Verification',
                                        html: html_email)

      MailService.send(mail_form: mail_form)
    end
  end
end
