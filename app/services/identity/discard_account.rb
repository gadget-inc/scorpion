# frozen_string_literal: true

# Implements a platform independent account discard process
class Identity::DiscardAccount
  def initialize(user)
    @user = user
  end

  def discard(account)
    Account.transaction do
      account.discard
    end

    [account, nil]
  end
end
