# frozen_string_literal: true

class CreateUserProviderIdentities < ActiveRecord::Migration[6.0]
  def change
    create_table :user_provider_identities do |t|
      t.bigint :user_id, null: false
      t.string :provider_name, null: false
      t.string :provider_id, null: false
      t.jsonb :provider_details, null: false, default: {}
      t.datetime :discarded_at, null: true

      t.timestamps
    end

    add_index :user_provider_identities, %i[discarded_at provider_name provider_id], name: "idx_identity_lookup"
    add_foreign_key :user_provider_identities, :users
  end
end
