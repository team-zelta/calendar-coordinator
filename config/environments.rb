# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require './app/lib/secure_db'

# CalendarCoordinator
module CalendarCoordinator
  # WebAPI environment configuration
  class API < Roda
    plugin :environments

    # Load configuration
    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    # Make the database accessible to other classes
    def self.config
      Figaro.env
    end

    DB = Sequel.connect(config.DATABASE_URL)

    def self.DB # rubocop:disable Naming/MethodName
      DB
    end

    configure :development, :test do
      require 'pry'
    end
  end
end
