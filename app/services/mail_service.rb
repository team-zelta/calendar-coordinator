# frozen_string_literal: true

require 'http'

module Common
  # Mail Service
  class MailService
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end

    MAIL_KEY = ENV['MAILGUN_API_KEY']
    MAIL_DOMAIN = ENV['MAILGUN_DOMAIN']
    MAIL_CREDENTIALS = "api:#{MAIL_KEY}"

    # Build Email Form
    def self.mail_form(from:, to:, subject:, text:, html:)
      {
        from: from,
        to: to,
        subject: subject,
        text: text,
        html: html
      }
    end

    # Send Email
    def self.send(mail_form:)
      mail_credentials = "api:#{MAIL_KEY}"
      mail_auth = Base64.strict_encode64(mail_credentials)
      mail_url = "https://#{mail_credentials}@api.mailgun.net/v3/#{MAIL_DOMAIN}/messages"

      HTTP.auth("basic #{mail_auth}").post(mail_url, form: mail_form)
    rescue StandardError => e
      puts "Email error: #{e.inspect}"
      raise(InvalidRegistration, 'Send Email failed')
    end
  end
end
