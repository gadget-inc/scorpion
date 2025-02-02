# frozen_string_literal: true

require "test_helper"

class Identity::CreateAccountTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @creator = Identity::CreateAccount.new(@user)
  end

  test "it creates an account" do
    assert_difference "Account.count", 1 do
      result, errors = @creator.create(name: "A test account")

      assert_nil errors
      result.reload

      assert_equal result.name, "A test account"
      assert_equal @user, result.creator
      assert_includes @user.reload.permissioned_accounts, result
    end
  end

  test "it returns errors if the account is invalid" do
    assert_difference "Account.count", 0 do
      result, errors = @creator.create(name: nil)

      assert_not_nil errors
      assert_nil result
    end
  end
end
