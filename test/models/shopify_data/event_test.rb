# frozen_string_literal: true

# == Schema Information
#
# Table name: shopify_data_events
#
#  id                 :bigint           not null, primary key
#  arguments          :string
#  author             :string
#  body               :string
#  description        :string
#  path               :string
#  shopify_created_at :datetime         not null
#  verb               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  event_id           :bigint           not null
#  shopify_shop_id    :bigint           not null
#  subject_id         :bigint           not null
#
# Indexes
#
#  index_shopify_data_events_on_event_id  (event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (shopify_shop_id => shopify_shops.id)
#
require "test_helper"

class ShopifyData::EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
