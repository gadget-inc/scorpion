# frozen_string_literal: true
class AddDiscardedAtToShopifyShops < ActiveRecord::Migration[6.0]
  def change
    add_column :shopify_shops, :discarded_at, :datetime
    remove_index :shopify_shops, :domain
    add_index :shopify_shops, %i[discarded_at domain]
  end
end
