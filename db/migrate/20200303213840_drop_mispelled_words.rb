# frozen_string_literal: true

class DropMispelledWords < ActiveRecord::Migration[6.0]
  def change
    drop_table :misspelled_words # rubocop:disable Rails/ReversibleMigration
  end
end
