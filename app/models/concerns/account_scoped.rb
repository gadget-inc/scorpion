# frozen_string_literal: true

# Implies the including model belongs to one account.
module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    validates :account_id, presence: true
  end
end
