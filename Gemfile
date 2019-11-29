# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.6.2'

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
gem 'rack-cors'
gem 'rails', '6.0.1'
gem 'webpacker'

# Functionality
gem 'money-rails'
gem 'rrule'
gem 'rails-i18n'

# Integrations
gem 'omniauth'

gem 'omniauth-shopify-oauth2'
gem 'shopify_api'

gem 'rest-client'
gem 'omniauth-google-oauth2'
gem 'google-api-client'

# Performance & Infrastructure
gem 'active_record_query_trace'
gem 'analytics-ruby', '~> 2.2.7', require: 'segment/analytics'
gem "annotate"
gem 'ar_transaction_changes'
gem "asset_sync"
gem "fog-google", '~> 1.9.1'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.1.0', require: false
gem "bullet", "~> 6.0.2"
gem "flipper", '~> 0.16', github: 'mokhan/flipper', branch: 'rails-6'
gem 'flipper-active_record', '~> 0.16', github: 'mokhan/flipper', branch: 'rails-6'
gem 'flipper-active_support_cache_store', '~> 0.16', github: 'mokhan/flipper', branch: 'rails-6'
gem 'flipper-ui'
gem "google-cloud-storage", require: false
gem "health_check"
gem 'hiredis'
gem 'json-schema'
gem "lru_redux"
gem "marginalia"
gem "mini_magick"
gem "oj"
gem "que", github: "que-rb/que", ref: "53106609b24d7e8bc231ae3883f69dca8c989d9d"
gem "que-scheduler"
gem "que-locks"
gem 'que-web'
gem 'rails-middleware-extensions'
gem 'rails_semantic_logger'
gem 'redis', '~> 4.1'
gem 'request_store'
gem "safely"
gem "scenic"
gem "sentry-raven"
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
  gem 'kubernetes-deploy'
  gem 'ejson'
end