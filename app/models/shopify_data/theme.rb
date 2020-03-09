# frozen_string_literal: true

# == Schema Information
#
# Table name: shopify_data_themes
#
#  id                   :bigint           not null, primary key
#  asset_change_tracker :jsonb            not null
#  name                 :string           not null
#  previewable          :boolean
#  processing           :boolean
#  role                 :string           not null
#  shopify_created_at   :datetime         not null
#  shopify_updated_at   :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  account_id           :bigint           not null
#  shopify_shop_id      :bigint           not null
#  theme_id             :bigint           not null
#  theme_store_id       :bigint
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)

# A synced version of a Shopify shop's theme.
class ShopifyData::Theme < ApplicationRecord
  include AccountScoped
  include ShopifyShopScoped

  has_many :theme_change_events, foreign_key: :shopify_data_theme_id, dependent: :destroy, inverse_of: :theme
  has_many :asset_change_events, foreign_key: :shopify_data_theme_id, dependent: :destroy, inverse_of: :theme
end
