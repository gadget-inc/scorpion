# frozen_string_literal: true

class Identity::UpdateAccount
  def initialize(account, user)
    @account = account
    @user = user
  end

  def update(account, attributes)
    success = Account.transaction do
      account.assign_attributes(attributes)
      account.save
    end

    if success
      [account, nil]
    else
      [nil, account.errors]
    end
  end
end
