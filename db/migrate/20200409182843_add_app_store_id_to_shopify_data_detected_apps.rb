# frozen_string_literal: true
class AddAppStoreIdToShopifyDataDetectedApps < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :shopify_data_detected_apps, :shopify_data_app_store_app_id, :bigint, null: true
    add_foreign_key :shopify_data_detected_apps, :shopify_data_app_store_apps

    ActiveRecord::Base.connection.execute("TRUNCATE shopify_data_detected_apps CASCADE;")
    add_column :shopify_data_detected_apps, :subject_key, :string, null: false, default: "unknown"
    change_column_default :shopify_data_detected_apps, :subject_key, from: "unknown", to: nil
    # rubocop:enable Rails/BulkChangeTable
  end
end
