# frozen_string_literal: true

require 'rake/testtask'
require_relative './require_app'

task default: :spec

desc 'Check Vulnerable Dependencies'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

desc 'Check Style and Performance'
task :style do
  sh 'rubocop'
end

desc 'Run application console (pry)'
task console: :print_env do
  sh 'pry -r ./require_app'
end

desc 'Print the environment'
task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

namespace :db do
  require_relative 'config/environments'
  require 'sequel'

  Sequel.extension :migration
  app = CalendarCoordinator::API

  desc 'Run migration'
  task migrate: :print_env do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'app/database/migrations')
  end

  desc 'Delete table'
  task :delete do
    app.DB[:events].delete
    app.DB[:calendars].delete
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/database/store/#{app.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end

  task :load_models do
    require_app(%w[lib models services])
  end

  task reset_seeds: [:load_models] do
    app.DB[:schema_seeds].delete if app.DB.tables.include?(:schema_seeds)
    CalendarCoordinator::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task seed: [:load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(app.DB, 'app/database/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: %i[reset_seeds seed]
end

namespace :newkey do
  desc 'Create sample cryptographic key for database'
  task :db do
    require_app('lib')
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end
