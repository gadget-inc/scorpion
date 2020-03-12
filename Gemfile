# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "2.7"

# Core web app
gem "discard"
gem "graphiql-rails"
gem "graphql"
gem "graphql-batch", require: "graphql/batch"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 4.3"
gem "rails", "~> 6.0.2"
gem "webpacker"
gem "rack-cors"
gem "fixings", github: "airhorns/fixings"

# Functionality
gem "rails-i18n"
gem "wisper"
gem "nokogiri"

# Integrations
gem "rest-client"
gem "omniauth"
gem "omniauth-shopify-oauth2"
gem "omniauth-google-oauth2"
gem "shopify_app"
gem "shopify_api"
gem "google-api-client"

# Performance & Infrastructure
gem "analytics-ruby", "~> 2.2.8", require: "segment/analytics"
gem "asset_sync"
gem "fog-google", "~> 1.9.1", github: "fog/fog-google"
gem "bootsnap", ">= 1.1.0", require: false
gem "google-cloud-storage", "~> 1.25.1", require: false
gem "hiredis"
gem "json-schema"
gem "image_processing"
gem "lru_redux"
gem "mini_magick"
gem "retriable", "~> 3.1"
gem "que", github: "que-rb/que", ref: "53106609b24d7e8bc231ae3883f69dca8c989d9d"
gem "que-scheduler"
gem "que-locks"
gem "que-web"
gem "redis", "~> 4.1"
gem "request_store"
gem "safely"
gem "scenic"
gem "sequenced"
gem "honeycomb-beeline", "~> 1.3.0", require: false # needs custom requiring in order to set up middleware properly, see initializer
gem "k8s-client"
gem "wait"
gem "zaru"

# Admin
gem "trestle"
gem "trestle-omniauth", "~> 0.2.0"  #, path: "~/Code/trestle-omniauth"
gem "trestle-search"
gem "trestle-jsoneditor"
gem "trestle-simplemde"
gem "sassc-rails" # required for "trestle-simplemde"
gem "pg_search"

group :development, :test, :integration_test do
  gem "awesome_print"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "faker"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "pry"
  gem "pry-byebug"
  gem "rcodetools"
  gem "rufo"
  gem "subprocess"
  gem "irb"
  gem "dotenv-rails"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.3"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

group :test do
  gem "timecop"
  gem "minitest-ci", require: !ENV["CI"].nil?
  gem "minitest-snapshots", "~> 0.3.0"
  gem "mocha"
  gem "webmock"
  gem "vcr"
  gem "test-prof"
end

group :development, :deploy do
  gem "krane", github: "airhorns/krane", ref: "googleauth-0.9"
  gem "ejson"
end
