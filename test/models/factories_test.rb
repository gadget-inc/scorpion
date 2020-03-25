# frozen_string_literal: true

require "test_helper"

class FactoriesTest < ActiveSupport::TestCase
  test "all factories pass lint" do
    FactoryBot.lint traits: true
  end

  # Because factory_bot magically materializes associations, unless the tree of all the stuff this creates
  # is very careful to pass the account instance down to each subresource created, those subresources will create
  # their own account instance, breaking the fixture and making things confusing. Hunting down which subresource
  # creates the extra account is tricky and at this point is mostly done by guessing.
  test "big account fixtures create only one account" do
    create(:account)
    assert_equal 1, Account.all.size
    assert_equal 1, User.all.size
    assert_equal 0, Property.all.size
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "property fixtures create only one shop" do
    create(:live_test_myshopify_property)
    assert_equal 1, Account.all.size
    assert_equal 1, Property.all.size
    assert_equal 1, ShopifyShop.all.size
  end

  test "shopify shop fixtures create only one shop" do
    create(:live_test_myshopify_shop)
    assert_equal 1, Account.all.size
    assert_equal 1, Property.all.size
    assert_equal 1, ShopifyShop.all.size
  end

  test "issue factories create only one issue" do
    assert_difference "Assessment::Issue.count", 1 do
      assert_difference "Assessment::IssueChangeEvent.count", 0 do
        assert_difference "Account.count", 1 do
          create(:assessment_issue)
        end
      end
    end

    assert_difference "Assessment::Issue.count", 1 do
      assert_difference "Assessment::IssueChangeEvent.count", 1 do
        assert_difference "Account.count", 1 do
          create(:assessment_issue_with_open_event)
        end
      end
    end
  end

  test "issue event factories create only one issue" do
    assert_difference "Assessment::Issue.count", 1 do
      assert_difference "Account.count", 1 do
        create(:assessment_issue_change_event)
      end
    end
  end
end
