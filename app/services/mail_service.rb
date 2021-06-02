# frozen_string_literal: true

require 'http'

module Common
  # Mail Service
  class MailService
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end

    MAIL_API_KEY = ENV['SENDGRID_API_KEY']
    MAIL_FROM = ENV['SENDGRID_FROM_EMAIL']
    MAIL_URL = 'https://api.sendgrid.com/v3/mail/send'

    # Build Email Form
    def self.mail_form(to:, subject:, html:) # rubocop:disable Metrics/MethodLength
      {
        personalizations: [{
          to: [{ 'email' => to }]
        }],
        from: { 'email' => MAIL_FROM },
        subject: subject,
        content: [
          { type: 'text/html',
            value: html }
        ]
      }
    end

    # Send Email
    def self.send(mail_form:)
      HTTP.auth("Bearer #{MAIL_API_KEY}").post(MAIL_URL, json: mail_form)
    rescue StandardError => e
      puts "Email error: #{e.inspect}"
      raise(InvalidRegistration, 'Send Email failed')
    end
  end
end
