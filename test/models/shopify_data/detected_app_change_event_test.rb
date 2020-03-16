# frozen_string_literal: true
# == Schema Information
#
# Table name: shopify_data_detected_app_change_events
#
#  id                           :bigint           not null, primary key
#  action                       :string           not null
#  action_at                    :datetime         not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  account_id                   :bigint           not null
#  shopify_data_detected_app_id :bigint           not null
#  shopify_shop_id              :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_data_detected_app_id => shopify_data_detected_apps.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)
#
require "test_helper"

class ShopifyData::DetectedAppChangeEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
