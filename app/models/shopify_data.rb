# frozen_string_literal: true
# Component for storing data from shopify, usually sent in via webhooks or periodically synced.
module ShopifyData
  def self.table_name_prefix
    "shopify_data_"
  end
end
