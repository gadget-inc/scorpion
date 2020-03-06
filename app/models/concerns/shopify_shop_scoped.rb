# frozen_string_literal: true

# Implies the including model belongs to only one shopify shop
module ShopifyShopScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :shopify_shop, optional: false
  end
end
