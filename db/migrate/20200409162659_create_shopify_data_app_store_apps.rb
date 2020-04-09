# frozen_string_literal: true
class CreateShopifyDataAppStoreApps < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_app_store_apps do |t|
      t.string :title, null: false
      t.string :app_store_url, null: false, index: { unique: true }
      t.string :app_store_developer_url, null: false
      t.string :developer_name, null: false
      t.string :category, null: false
      t.string :image_url, null: false

      t.string :developer_url
      t.string :faq_url

      t.string :inferred_domains, null: false, array: true
      t.string :confirmed_domains, null: false, array: true
      t.integer :priority, null: false

      t.timestamps
    end
  end
end
