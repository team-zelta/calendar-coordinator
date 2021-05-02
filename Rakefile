# frozen_string_literal: true

require 'rake/testtask'
require_relative './require_app'

desc 'Check Vulnerable Dependencies'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Ruby Test'
Rake::TestTask.new(:spec) do |t|
  t.test_files = FileList['spec/*.rb']
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
end

namespace :newkey do
  desc 'Create sample cryptographic key for database'
  task :db do
    require_app('lib')
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end
