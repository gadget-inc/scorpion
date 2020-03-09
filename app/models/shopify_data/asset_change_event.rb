# frozen_string_literal: true
# == Schema Information
#
# Table name: shopify_data_asset_change_events
#
#  id                    :bigint           not null, primary key
#  action                :string
#  action_at             :datetime         not null
#  key                   :string           not null
#  account_id            :bigint           not null
#  shopify_data_theme_id :bigint           not null
#  shopify_shop_id       :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_data_theme_id => shopify_data_themes.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)

# Represents a point in time record of a Shopify shop's theme asset being changed
class ShopifyData::AssetChangeEvent < ApplicationRecord
  include AccountScoped
  include ShopifyShopScoped

  belongs_to :theme, foreign_key: :shopify_data_theme_id, inverse_of: :asset_change_events
end
