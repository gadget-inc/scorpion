# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.6.4'

# Core web app
gem 'devise', '~> 4.7.1'
gem 'devise_invitable'
gem 'devise-jwt'
gem 'discard'
gem 'graphiql-rails'
gem 'graphql'
gem 'graphql-batch', require: "graphql/batch"
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'rails', '6.0.1'
gem 'webpacker'
gem 'fixings', '0.1.2'

# Functionality
gem 'money-rails'
gem 'rrule'
gem 'rails-i18n'
gem 'hunspell'
gem 'ffi-hunspell', require: "ffi/hunspell"
gem 'cld3'

# Integrations
gem 'omniauth'

gem 'omniauth-shopify-oauth2'
gem 'shopify_api'

gem 'rest-client'
gem 'omniauth-google-oauth2'
gem 'google-api-client'

# Performance & Infrastructure
gem 'analytics-ruby', '~> 2.2.7', require: 'segment/analytics'
gem "asset_sync"
gem "fog-google", '~> 1.9.1'
gem 'bootsnap', '>= 1.1.0', require: false
gem "google-cloud-storage", require: false
gem 'hiredis'
gem 'image_processing'
gem 'json-schema'
gem "lru_redux"
gem "mini_magick"
gem "que", github: "que-rb/que", ref: "53106609b24d7e8bc231ae3883f69dca8c989d9d"
gem "que-scheduler"
gem "que-locks"
gem 'que-web'
gem 'redis', '~> 4.1'
gem 'request_store'
gem "safely"
gem "scenic"
gem "honeycomb-beeline", '~> 1.2.0', require: false # needs custom requiring in order to set up middleware properly, see initializer
gem 'k8s-client'
gem 'wait'
gem 'zaru'

# Admin
gem 'trestle', '~> 0.9.0'
gem 'trestle-omniauth', '~> 0.2.0'  #, path: "~/Code/trestle-omniauth"

group :development, :test, :integration_test do
  gem 'awesome_print'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rcodetools'
  gem 'rufo'
  gem 'subprocess'
  gem 'irb'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'solargraph'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

group :test do
  gem 'timecop'
  gem 'minitest-ci', require: !ENV['CI'].nil?
  gem 'minitest-snapshots', '~> 0.3.0'
  gem 'mocha'
  gem 'webmock'
  gem 'vcr'
end

group :development, :deploy do
  gem 'krane'
  gem 'ejson'
end
