# frozen_string_literal: true

# == Schema Information
#
# Table name: assessment_issues
#
#  id           :bigint           not null, primary key
#  closed_at    :datetime
#  key          :string           not null
#  key_category :string           not null
#  number       :integer          not null
#  opened_at    :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint           not null
#  property_id  :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#
class Assessment::Issue < ApplicationRecord
  include AccountScoped
  belongs_to :property

  has_many :results, class_name: "Assessment::Result", dependent: :destroy
  acts_as_sequenced column: :number, scope: :account_id, start_at: 1
end
