# frozen_string_literal: true

class AddNonNullToAssetChangeEventActions < ActiveRecord::Migration[6.0]
  def change
    change_column :shopify_data_asset_change_events, :action, :string, null: false
  end
end
