# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require_app('lib')

# CalendarCoordinator
module CalendarCoordinator
  # WebAPI environment configuration
  class API < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config() = Figaro.env

    # Logger setup
    LOGGER = Logger.new($stderr)
    def self.logger() = LOGGER

    # Database Setup
    DB = Sequel.connect(ENV.delete('DATABASE_URL'))
    def self.DB() = DB # rubocop:disable Naming/MethodName

    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end

    configure do
      SecureDB.setup(ENV.delete('DB_KEY'))
      AuthToken.setup(ENV.delete('MSG_KEY'))
    end
  end
end
