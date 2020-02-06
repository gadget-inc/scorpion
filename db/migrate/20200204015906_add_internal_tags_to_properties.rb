# frozen_string_literal: true

class AddInternalTagsToProperties < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :internal_tags, :string, array: true, default: []
  end
end
