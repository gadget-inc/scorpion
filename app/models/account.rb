# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id            :bigint           not null, primary key
#  discarded_at  :datetime
#  internal_tags :string           default("{}"), not null, is an Array
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  creator_id    :bigint           not null
#
# Indexes
#
#  index_accounts_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
# Root object grouping together access and settings for a bunch of properties. The billing entity.
class Account < ApplicationRecord
  include Discard::Model
  include MutationClientId

  validates :name, presence: true
  validates :creator, presence: true

  has_many :account_user_permissions, inverse_of: :account, dependent: :destroy
  has_many :permissioned_users, through: :account_user_permissions, source: :user

  has_many :properties, inverse_of: :account, dependent: :destroy
  has_many :crawl_attempts, class_name: "Crawl::Attempt", inverse_of: :account, dependent: :destroy
  has_many :property_screenshots, inverse_of: :account, dependent: :destroy
  has_many :assessment_results, class_name: "Assessment::Result", inverse_of: :account, dependent: :destroy

  belongs_to :creator, class_name: "User", inverse_of: :created_accounts

  admin_searchable :name, :internal_tags

  def flipper_id
    @flipper_id ||= "account-#{id}"
  end
end
