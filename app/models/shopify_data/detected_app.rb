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

# Represents one app that we've found on a shopify storefront for the lifecycle that we can see it
class ShopifyData::DetectedApp < ApplicationRecord
  include AccountScoped
  belongs_to :shopify_shop, optional: false
  belongs_to :app_store_app, optional: true, class_name: "ShopifyData::AppStoreApp", foreign_key: :shopify_data_app_store_app_id, inverse_of: false
  has_many :detected_app_change_events, class_name: "ShopifyData::DetectedAppChangeEvent", foreign_key: :shopify_data_detected_app_id, dependent: :destroy, inverse_of: :detected_app
end
