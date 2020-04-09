# frozen_string_literal: true
# == Schema Information
#
# Table name: shopify_data_app_store_apps
#
#  id                      :bigint           not null, primary key
#  app_store_developer_url :string           not null
#  app_store_url           :string           not null
#  category                :string           not null
#  confirmed_domains       :string           not null, is an Array
#  developer_name          :string           not null
#  developer_url           :string
#  faq_url                 :string
#  image_url               :string           not null
#  inferred_domains        :string           not null, is an Array
#  priority                :integer          not null
#  title                   :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_shopify_data_app_store_apps_on_app_store_url  (app_store_url) UNIQUE
#
require "test_helper"

class ShopifyData::AppStoreAppTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
