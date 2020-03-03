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
#
require "test_helper"

class ShopifyData::AssetChangeEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
