# frozen_string_literal: true

class RemoveDeviseFromUsers < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    remove_column :users, :confirmation_sent_at, :datetime
    remove_column :users, :confirmation_token, :string
    remove_column :users, :confirmed_at, :datetime
    remove_column :users, :current_sign_in_at, :datetime
    remove_column :users, :current_sign_in_ip, :inet
    remove_column :users, :encrypted_password, :string, null: false
    remove_column :users, :failed_attempts, :integer, null: false, default: 0
    remove_column :users, :invitation_accepted_at, :datetime
    remove_column :users, :invitation_created_at, :datetime
    remove_column :users, :invitation_limit, :integer
    remove_column :users, :invitation_sent_at, :datetime
    remove_column :users, :invitation_token, :string
    remove_column :users, :invitations_count, :integer, default: 0
    remove_column :users, :invited_by_type, :string
    remove_column :users, :invited_by_id, :bigint
    remove_column :users, :last_sign_in_at, :datetime
    remove_column :users, :last_sign_in_ip, :inet
    remove_column :users, :locked_at, :datetime
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :reset_password_token, :string
    remove_column :users, :unconfirmed_email, :string
    remove_column :users, :unlock_token, :string
    # rubocop:enable Rails/BulkChangeTable
  end
end
