# frozen_string_literal: true

# == Schema Information
#
# Table name: misspelled_words
#
#  id               :bigint           not null, primary key
#  count            :integer          not null
#  seen_on_pages    :string           is an Array
#  suggestions      :string           is an Array
#  word             :string           not null
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

class MisspelledWord < ApplicationRecord
  include AccountScoped

  belongs_to :property, optional: false
  belongs_to :crawl_attempt, optional: false
end
