# frozen_string_literal: true

# == Schema Information
#
# Table name: properties
#
#  id                    :bigint           not null, primary key
#  allowed_domains       :string           not null, is an Array
#  ambient               :boolean          default(FALSE)
#  crawl_roots           :string           not null, is an Array
#  discarded_at          :datetime
#  enabled               :boolean          default(TRUE), not null
#  internal_tags         :string           default([]), is an Array
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

require "test_helper"

class PropertyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
