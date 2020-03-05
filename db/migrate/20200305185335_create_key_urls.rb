# frozen_string_literal: true
class CreateKeyUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :key_urls do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.bigint :creator_id
      t.string :url, null: false
      t.string :page_type, null: false
      t.string :creation_reason, null: false

      t.timestamps
    end

    add_foreign_key :key_urls, :accounts
    add_foreign_key :key_urls, :properties
    add_foreign_key :key_urls, :users, column: :creator_id
  end
end
