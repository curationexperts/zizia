# frozen_string_literal: true
Capybara.default_max_wait_time = 20

# Setup chrome headless driver
Capybara.server = :puma, { Silent: true }

Capybara.register_driver :chrome_headless do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 240
  client.open_timeout = 240
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

# Setup rspec
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :chrome_headless
  end
end
