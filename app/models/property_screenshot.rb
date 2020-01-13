# frozen_string_literal: true

# == Schema Information
#
# Table name: property_screenshots
#
#  id               :bigint           not null, primary key
#  result           :jsonb            not null
#  url              :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  crawl_attempt_id :bigint           not null
#  property_id      :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (crawl_attempt_id => crawl_attempts.id)
#  fk_rails_...  (property_id => properties.id)
#

class PropertyScreenshot < ApplicationRecord
  include AccountScoped

  belongs_to :property, optional: false, inverse_of: :property_screenshots
  belongs_to :crawl_attempt, optional: false, inverse_of: :property_screenshots

  has_one_attached :image
end
