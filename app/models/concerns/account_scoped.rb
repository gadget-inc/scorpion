# frozen_string_literal: true

# Implies the including model belongs to one account.
module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    validate :validate_account_is_set
  end

  # Use a custom validator here to first check the account_id column and then check the association column
  # This prevents superfluous loads of the account record just to validate.
  def validate_account_is_set
    if account_id.blank? && account.blank?
      errors.add(:account, "must be set")
    end
  end
end
