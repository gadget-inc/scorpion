# frozen_string_literal: true

require "test_helper"

class Admin::CrawlAttemptsAdmin < ActionDispatch::IntegrationTest
  include AdminAuthTestHelper

  setup do
    host! Rails.configuration.x.domains.admin
    @account = create(:account)
    @properties = create_list(:property, 3, account: @account)
    @property = create(:ambient_homesick_property, account: @account)
    @attempts = create_list(:crawl_attempt, 3, property: @property)

    admin_login!
  end

  test "can visit the index" do
    get "/crawl/attempts"
    assert_response :success
  end

  test "can visit the show and edit" do
    get "/crawl/attempts/#{@attempts[0].id}"
    assert_response :success

    get "/crawl/attempts/#{@attempts[0].id}/edit"
    assert_response :success
  end
end
