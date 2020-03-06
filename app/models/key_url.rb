# frozen_string_literal: true
# == Schema Information
#
# Table name: key_urls
#
#  id              :bigint           not null, primary key
#  creation_reason :string           not null
#  page_type       :string           not null
#  url             :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint           not null
#  creator_id      :bigint
#  property_id     :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (property_id => properties.id)
#
# Represents an important URL for a property, which implies we should assess it more often.
class KeyUrl < ApplicationRecord
  include AccountScoped

  belongs_to :property, optional: false, inverse_of: :key_urls
end
