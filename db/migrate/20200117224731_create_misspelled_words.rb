# frozen_string_literal: true
class CreateMisspelledWords < ActiveRecord::Migration[6.0]
  def change
    create_table :misspelled_words do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.bigint :crawl_attempt_id, null: false
      t.string :word, null: false
      t.string :seen_on_pages, array: true
      t.integer :count, null: false
      t.string :suggestions, array: true

      t.timestamps
    end

    add_foreign_key :misspelled_words, :accounts
    add_foreign_key :misspelled_words, :properties
    add_foreign_key :misspelled_words, :crawl_attempts
  end
end
