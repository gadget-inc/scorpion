# frozen_string_literal: true

# Implements a platform independent account creation process.
class Identity::CreateAccount
  def initialize(creator)
    @creator = creator
  end

  def create(new_attributes)
    new_account = Account.new(creator_id: @creator.id)
    new_account.assign_attributes(new_attributes)
    new_account.account_user_permissions.build(user: @creator)
    success = new_account.save

    if success
      [new_account, nil]
    else
      [nil, new_account.errors]
    end
  end

  def create!(new_attributes)
    new_account, errors = create(new_attributes)

    if errors
      raise ActiveRecord::RecordNotSaved.new("Failed to save the record", new_account)
    end

    new_account
  end
end
