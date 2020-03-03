# frozen_string_literal: true

# == Schema Information
#
# Table name: shopify_data_shop_change_events
#
#  id               :bigint           not null, primary key
#  new_value        :jsonb
#  old_value        :jsonb
#  record_attribute :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  shopify_shop_id  :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)
#
require "test_helper"

class ShopifyData::ShopChangeEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
