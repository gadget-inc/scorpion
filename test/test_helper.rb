# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "fixings/test_help"

# Setup some env vars that devs might pass in for VCR to record real requests, then replace them with VCR's sensitive data filters so the cassettes are safe to commit to Git.
# If you want to re-record VCR data, set these variables in your environment before running your tests. `bin/rake dev:env_vars` will spit as many of them as it can out from your development database to then use to create VCR fixtures.
ENV["GA_OAUTH_ACCESS_TOKEN"] ||= "test_access_token"
ENV["GA_OAUTH_REFRESH_TOKEN"] ||= "test_refresh_token"
ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"] ||= "test.myshopify.com"
ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"] ||= "test_access_token"
ENV["KAFKA_SASL_PLAIN_PASSWORD"] ||= "test_kafka_password"
ENV["FB_OAUTH_ACCESS_TOKEN"] ||= "test_access_token"

VCR.configure do |config|
  config.filter_sensitive_data("<GA_OAUTH_ACCESS_TOKEN>") { ENV["GA_OAUTH_ACCESS_TOKEN"] }
  config.filter_sensitive_data("<GA_OAUTH_REFRESH_TOKEN>") { ENV["GA_OAUTH_REFRESH_TOKEN"] }
  config.filter_sensitive_data("<FB_OAUTH_ACCESS_TOKEN>") { ENV["FB_OAUTH_ACCESS_TOKEN"] }
  config.filter_sensitive_data("<SHOPIFY_SHOP_OAUTH_DOMAIN>") { ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"] }
  config.filter_sensitive_data("<SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN>") { ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"] }
  config.filter_sensitive_data("<KAFKA_SASL_PLAIN_PASSWORD>") { ENV["KAFKA_SASL_PLAIN_PASSWORD"] }
  config.filter_sensitive_data("<KUBE_CLUSTER_ADDRESS>") { "kubernetes.docker.internal:6443" }

  config.fixings_query_matcher_param_exclusions << "appsecret_proof"
end

OmniAuth.config.test_mode = true

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include GraphQLTestHelper

  # Run tests in parallel with specified workers
  if ENV["CI"] || ENV["PARALLEL"]
    parallelize(workers: :number_of_processors)
  end

  teardown do
    OmniAuth.config.mock_auth[:shopify] = nil
    Timecop.return
  end

  def with_synchronous_jobs
    old_value = Que::Job.run_synchronously
    Que::Job.run_synchronously = true
    yield
  ensure
    Que::Job.run_synchronously = old_value
  end

  def raise_on_unoptimized_queries
    old_enabled = Bullet.enable?
    Bullet.enable = true
    Bullet.raise = true
    yield
  ensure
    Bullet.enable = old_enabled
    Bullet.raise = false
  end

  def assert_string_like(expected, actual)
    assert_equal expected.gsub(/\s+/, " ").strip, actual.gsub(/\s+/, " ").strip
  end
end
