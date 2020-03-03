# frozen_string_literal: true

# == Schema Information
#
# Table name: shopify_data_theme_change_events
#
#  id                    :bigint           not null, primary key
#  new_value             :jsonb
#  old_value             :jsonb
#  record_attribute      :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :bigint           not null
#  shopify_data_theme_id :bigint           not null
#  shopify_shop_id       :bigint           not null
#
# Indexes
#
#  idx_theme_changes_cursor_lookup  (account_id,shopify_shop_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_data_theme_id => shopify_data_themes.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)
#
class ShopifyData::ThemeChangeEvent < ApplicationRecord
  include AccountScoped
  include ShopifyShopScoped

  belongs_to :theme, foreign_key: :shopify_data_theme_id, inverse_of: :asset_change_events
end
