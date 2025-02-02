# frozen_string_literal: true
require "connection_pool"
Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(Rails.configuration.redis) }
