# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.2"

gem "scout_apm" # needs to be first

gem "active_storage_validations"
gem "acts_as_list"
gem "acts-as-taggable-on", "~> 9.0"
gem "ahoy_email"
gem "ahoy_matey"
gem "awesome_print"
gem "aws-sdk-s3", require: false
gem "blazer"
gem "bootsnap", require: false
gem "chroma"
gem "colorize"
gem "devise"
gem "devise_invitable"
gem "faraday"
gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"
gem "honeybadger", "~> 4.0"
gem "humanize"
gem "icalendar"
gem "ice_cube"
gem "image_processing"
gem "importmap-rails"
gem "ledermann-rails-settings"
gem "lograge"
gem "loofah", ">= 2.19.1"
gem "mixpanel-ruby"
gem "nokogiri", ">= 1.13.10"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "paper_trail"
gem "pg"
gem "phony_rails"
gem "puma", "~> 5.0"
gem "pundit"
gem "rack-attack"
gem "rack-cors"
gem "rails", "~> 7.0.0"
gem "rails-html-sanitizer", ">= 1.4.4"
gem "remote_syslog_logger"
gem "rexml"
gem "rubocop", require: false
gem "sass-rails", "~> 6.0"
gem "seedbank"
gem "sentry-ruby"
gem "sidekiq"
# gem "sidekiq_alive"
gem "sidekiq-scheduler"
gem "slim"
gem "smarter_csv"
gem "sprockets-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "timecop"
gem "trix"
gem "turbo-rails"
gem "twilio-ruby"
gem "wicked_pdf"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", "~> 11.1", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails", "~> 2.7", groups: %i[development test]
  gem "rspec-rails", "~> 5.0"
end

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "factory_bot_rails", "~> 6.2"
  gem "web-console", "~> 4.1"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "listen", "~> 3.7"
  gem "rack-mini-profiler", "~> 2.3"
  gem "ruby-lsp", "~> 0.3.7"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem "spring", "~> 2.1"
end

group :test do
  gem "capybara"
  gem "faker"
  gem "launchy"
  gem "simplecov", require: false
  # gem "webdrivers"
  gem "apparition"
end

# Use Redis for Action Cable
gem "redis", "~> 4.0"
