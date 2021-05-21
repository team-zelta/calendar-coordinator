# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5'
gem 'roda', '~>3'

# Performance
gem 'rubocop-performance'

# Security
gem 'bundler-audit'
gem 'rbnacl'

# Encode
gem 'base64'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
end

# Configuration
gem 'figaro'
gem 'rake'

# Database
gem 'hirb'
gem 'sequel'
group :development, :test do
  gem 'sqlite3'
end
group :production do
  gem 'pg'
end

# Development
gem 'pry'
gem 'rubocop'
group :development do
  gem 'solargraph'
end
