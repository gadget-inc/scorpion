# frozen_string_literal: true
class RemoveDefaultFromShopifyShop < ActiveRecord::Migration[6.0]
  def change
    change_column_null :shopify_shops, :myshopify_domain, false
    change_column_default :shopify_shops, :myshopify_domain, from: "unknown", to: nil
  end
end
