class AddAmbientToProperties < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :ambient, :boolean, default: false
  end
end
