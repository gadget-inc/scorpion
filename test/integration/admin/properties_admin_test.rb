# frozen_string_literal: true

require "test_helper"

class Admin::PropertiesAdminTest < ActionDispatch::IntegrationTest
  include AdminAuthTestHelper

  setup do
    host! Rails.configuration.x.domains.admin
    @account = create(:account)
    @properties = create_list(:property, 3, account: @account)
    @property = create(:ambient_homesick_property, account: @account)

    admin_login!
  end

  test "can visit the index" do
    get "/properties"
    assert_response :success
  end

  test "can visit the show and edit" do
    get "/properties/#{@property.id}"
    assert_response :success

    get "/properties/#{@property.id}/edit"
    assert_response :success
  end
end
