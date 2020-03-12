# frozen_string_literal: true

# == Schema Information
#
# Table name: assessment_descriptors
#
#  id          :bigint           not null, primary key
#  description :string           not null
#  key         :string           not null
#  severity    :string           not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_assessment_descriptors_on_key  (key) UNIQUE
#
module Assessment
  # Represents one type of assessment that can be made and stores the details of what that assessment passing or failing means, and how to remedy it
  # Not account specific -- more of a lookup table
  class Descriptor < ApplicationRecord
    validates :key, presence: true, format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9-]+\Z/ }, uniqueness: true
    validates :title, presence: true
    validates :severity, presence: true
    validates :description, presence: true

    enum severity: { low: "low", warning: "warning", error: "error", urgent: "urgent" }, _prefix: :type
  end
end
