# frozen_string_literal: true

# == Schema Information
#
# Table name: user_provider_identities
#
#  id               :bigint           not null, primary key
#  discarded_at     :datetime
#  provider_details :jsonb            not null
#  provider_name    :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  provider_id      :string           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  idx_identity_lookup  (discarded_at,provider_name,provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)

# Represents an authorization and identification mechanism for a user implemented by someone other than us, like Shopify.
class UserProviderIdentity < ApplicationRecord
  include Discard::Model
  belongs_to :user, optional: false
end
