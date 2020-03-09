# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  full_name     :string
#  internal_tags :string           default("{}"), not null, is an Array
#  sign_in_count :integer          default("0"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE

# Represents a person in the world who has access to the application. Can belong to multiple accounts and can be authenticated in a variety of ways. Or, at least should.
class User < ApplicationRecord
  include Discard::Model
  include MutationClientId

  # Creations
  has_many :created_accounts, foreign_key: :creator_id, inverse_of: :creator, class_name: "Account", dependent: :restrict_with_exception
  has_many :created_properties, foreign_key: :creator_id, inverse_of: :creator, class_name: "Property", dependent: :restrict_with_exception

  # Auth
  has_many :provider_identities, inverse_of: :user, dependent: :destroy, class_name: "UserProviderIdentity"
  has_many :account_user_permissions, inverse_of: :user, dependent: :destroy
  has_many :permissioned_accounts, through: :account_user_permissions, source: :account

  validates :full_name, presence: true

  def flipper_id
    "user-#{id}"
  end
end
