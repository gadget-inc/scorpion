# frozen_string_literal: true

# == Schema Information
#
# Table name: shopify_shops
#
#  id           :bigint           not null, primary key
#  api_token    :string           not null
#  discarded_at :datetime
#  domain       :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint           not null
#  creator_id   :bigint
#  property_id  :bigint           not null
#
# Indexes
#
#  index_shopify_shops_on_discarded_at_and_domain  (discarded_at,domain)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (property_id => properties.id)
#

class ShopifyShop < ApplicationRecord
  include AccountScoped
  include Discard::Model

  validates :api_token, presence: true
  validates :api_version, presence: true
  validates :domain, presence: true

  belongs_to :property
  belongs_to :creator, class_name: "User", optional: false

  has_many :data_events, class_name: "ShopifyData::Event", dependent: :destroy
  has_many :data_themes, class_name: "ShopifyData::Theme", dependent: :destroy

  def api_version
    ShopifyApp.configuration.api_version
  end

  def with_shopify_session(&block)
    ShopifyAPI::Session.temp(
      domain: domain,
      token: api_token,
      api_version: api_version,
      &block
    )
  end
end
