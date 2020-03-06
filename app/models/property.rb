# frozen_string_literal: true

# == Schema Information
#
# Table name: properties
#
#  id                    :bigint           not null, primary key
#  allowed_domains       :string           not null, is an Array
#  ambient               :boolean          default("false")
#  crawl_roots           :string           not null, is an Array
#  discarded_at          :datetime
#  enabled               :boolean          default("true"), not null
#  internal_tags         :string           default("{}"), is an Array
#  internal_test_options :jsonb
#  name                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :bigint           not null
#  creator_id            :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (creator_id => users.id)
#
# Represents one end-customer facing web site that we assess. Can be multiple per account. Assumed one property is powered by one platform. Doesn't have to live at just one domain, but usually does.
class Property < ApplicationRecord
  include AccountScoped
  include Discard::Model

  attribute :internal_test_options, JsonbTypeValue.new

  scope :for_purposeful_crawls, -> { kept.where(enabled: true, ambient: false) }
  scope :for_ambient_crawls, -> { kept.where(enabled: true, ambient: true) }

  belongs_to :creator, class_name: "User", inverse_of: :created_accounts

  has_many :key_urls, dependent: :destroy
  has_many :crawl_attempts, class_name: "Crawl::Attempt", dependent: :destroy
  has_many :property_screenshots, dependent: :destroy
  has_many :activity_feed_items, dependent: :destroy, class_name: "Activity::FeedItem"
  has_many :assessment_results, class_name: "Assessment::Result", inverse_of: :property, dependent: :destroy

  has_many :crawl_test_cases, class_name: "CrawlTest::Case", dependent: :destroy

  # for trestle's array assignment
  remove_blanks_for_array_assignment :allowed_domains, :crawl_roots, :internal_tags

  admin_searchable :name, :allowed_domains, :internal_tags
end
