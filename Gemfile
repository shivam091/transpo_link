# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.7"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"

# Add bootstrap support
gem "bootstrap", "~> 5.3.5"

gem "dartsass-rails"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Flexible authentication solution for Rails with Warden
gem "devise", "4.9.4"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 2.1"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3"

# Library for dealing with money and currency conversion
gem "money", "6.19"

# Collection of all sorts of useful information for every country in the ISO 3166 standard
gem "countries"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# IP address lookup
gem "IPinfo", "~> 2"

# HTML Abstraction Markup Language. Use Haml as Templating Language
gem "haml", "~> 6.3"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache", "~> 1.0"
gem "solid_queue", "~> 1.1"
gem "solid_cable", "~> 3.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# PostgreSQL Adapter Extensions for ActiveRecord
gem "postgresql_adapter_extensions", "~> 1"

# Loofah is a general library for manipulating and transforming HTML/XML documents and fragments.
gem "loofah", "~> 2"

# State machines for Ruby classes.
gem "aasm", "~> 5"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Alternative testing tool for Ruby on Rails
  gem "rspec-rails", "~> 8.0"

  # Provides one-liners to test common Rails functionality
  gem "shoulda-matchers", "~> 6.5"

  # Clean your ActiveRecord databases with database cleaner.
  gem "database_cleaner", "~> 2.1"

  # Fixtures replacement with a straightforward definition syntax.
  gem "factory_bot_rails", "~> 6.4"

  # Code coverage analysis tool for Ruby.
  gem "simplecov", require: false

  # Support simple parameterized test syntax in RSpec.
  gem "rspec-parameterized"

  # Test Rails generators with RSpec using the standard Rails::Generators::TestCase assertion methods.
  gem "generator_spec"

  # Help to kill N+1 queries and unused eager loading
  gem "bullet", "~> 8"

  # Generate realistic test data
  gem "faker"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
