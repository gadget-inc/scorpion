# frozen_string_literal: true

require "test_helper"

class CrawlTest::TesterTest < ActiveSupport::TestCase
  setup do
    @ambient_homesick = create(:ambient_homesick_property)
    @ambient_failure = create(:ambient_failure_property)
  end

  test "raises if no properties are found for criteria" do
    assert_raises do
      CrawlTest::Tester.new.enqueue_run(endpoint: "/test", user: "harry", property_limit: 10, property_criteria: "notfound")
    end
  end

  test "enqueues test cases and jobs for the ambient properties" do
    CrawlTest::Tester.new.enqueue_run(endpoint: "/test", user: "harry", property_limit: 10, property_criteria: "test_crawl")

    test_case = CrawlTest::Case.where(property_id: @ambient_homesick.id).first
    assert test_case
    assert_not test_case.running
    assert_not test_case.successful

    test_run = test_case.crawl_test_run

    assert test_run
    assert_not test_run.running
    assert_not test_run.successful
  end

  test "can execute test cases" do
    tester = CrawlTest::Tester.new
    tester.enqueue_run(endpoint: "/interaction/shopify_browse_add", user: "harry", property_limit: 10)

    test_case = CrawlTest::Case.where(property_id: @ambient_homesick.id).first
    assert test_case

    tester.execute_case(test_case)

    test_case.reload
    assert test_case.successful
    assert_not test_case.running
    assert test_case.finished_at
  end

  test "can execute failing test cases" do
    tester = CrawlTest::Tester.new
    tester.enqueue_run(endpoint: "/interaction/shopify_browse_add", user: "harry", property_limit: 10)

    test_case = CrawlTest::Case.where(property_id: @ambient_failure.id).first
    assert test_case

    assert_raises do
      tester.execute_case(test_case)
    end

    test_case.reload
    assert_not test_case.successful
    assert_not test_case.running
    assert test_case.finished_at
    assert test_case.screenshot.attached?
    assert test_case.last_html.present?
  end
end
