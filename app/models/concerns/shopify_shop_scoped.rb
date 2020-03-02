# frozen_string_literal: true

module ShopifyShopScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :shopify_shop, optional: false
  end
end
