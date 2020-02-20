# frozen_string_literal: true

class AddInternalConfigBlobToProperties < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :internal_test_options, :jsonb
  end
end
