# frozen_string_literal: true
require "retriable"

# Shopify API quota limit and error retry and backoff
module ShopifyData::ShopifyApiRetries
  def with_retries
    Retriable.retriable(on: ActiveResource::ClientError, tries: 6) do
      yield
    end
  end
end
