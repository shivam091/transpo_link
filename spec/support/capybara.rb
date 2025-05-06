# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/support/capybara.rb

require "capybara/rspec"
require "selenium/webdriver"

# Optional: You can pin a specific chromedriver version to match your Chrome version
# Webdrivers::Chromedriver.version = "135.0.7049.114"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # Modern flags for headless mode
  # options.binary = "/usr/bin/google-chrome-stable"
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,900")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

# Set default driver and JS driver
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :headless_chrome

# Optional: Adjust default max wait time for slower JavaScript responses
Capybara.default_max_wait_time = 5
