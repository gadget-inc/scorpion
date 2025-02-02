# frozen_string_literal: true

class CreatePostgresExtensions < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE EXTENSION pg_trgm;"
    execute "CREATE EXTENSION fuzzystrmatch;"
  end

  def down
    execute "DROP EXTENSION pg_trgm;"
    execute "DROP EXTENSION fuzzystrmatch;"
  end
end
