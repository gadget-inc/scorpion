# frozen_string_literal: true
# == Schema Information
#
# Table name: shopify_data_detected_apps
#
#  id                            :bigint           not null, primary key
#  first_seen_at                 :datetime         not null
#  last_seen_at                  :datetime         not null
#  name                          :string           not null
#  reasons                       :string           not null, is an Array
#  seen_last_time                :boolean          not null
#  subject_key                   :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  account_id                    :bigint           not null
#  shopify_data_app_store_app_id :bigint
#  shopify_shop_id               :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_data_app_store_app_id => shopify_data_app_store_apps.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)
#
require "test_helper"

class ShopifyData::DetectedAppTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
