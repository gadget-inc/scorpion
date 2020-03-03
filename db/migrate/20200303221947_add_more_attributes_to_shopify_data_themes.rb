# frozen_string_literal: true

class AddMoreAttributesToShopifyDataThemes < ActiveRecord::Migration[6.0]
  def change
    change_table :shopify_data_themes, bulk: true do
      t.boolean :processing
      t.boolean :previewable
    end
  end
end
