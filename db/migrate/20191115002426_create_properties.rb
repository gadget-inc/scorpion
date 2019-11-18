# frozen_string_literal: true
class CreateProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :properties do |t|
      t.bigint :account_id, null: false
      t.bigint :creator_id, null: false
      t.string :name, null: false
      t.string :crawl_roots, null: false, array: true
      t.string :allowed_domains, null: false, array: true

      t.timestamps
    end

    add_foreign_key :properties, :accounts
    add_foreign_key :properties, :users, column: :creator_id
  end
end
