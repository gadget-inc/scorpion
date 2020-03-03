# frozen_string_literal: true
module ShopifyData::ShopifyApiRetries
  def with_retries
    Retriable.retriable(on: ActiveResource::ClientError, tries: 6) do
      yield
    end
  end
end
