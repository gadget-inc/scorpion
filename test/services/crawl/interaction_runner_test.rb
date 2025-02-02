# frozen_string_literal: true

require "test_helper"

class Crawl::InteractionRunnerTest < ActiveSupport::TestCase
  test "it interacts against a test shop" do
    @property = create(:harry_test_charlie_property)
    @runner = runner_for_property(@property)

    assert_difference "Crawl::Attempt.count", 1 do
      @runner.test_interaction("shopify-browse-add")
    end

    attempt = @property.crawl_attempts.last
    assert_not_nil attempt.finished_at
    assert attempt.succeeded

    assert_equal 1, @property.assessment_results.size
    result = @property.assessment_results.last
    assert_not_nil result.score
    assert_nil result.error_code
  end

  test "it crawls a shop that can't be connected to exist and logs error results" do
    @property = create(:doesnt_exist_property)
    @runner = runner_for_property(@property)

    assert_difference "Crawl::Attempt.count", 1 do
      @runner.test_interaction("shopify-browse-add")
    end

    attempt = @property.crawl_attempts.last
    assert_not_nil attempt.finished_at
    assert attempt.succeeded

    assert_equal 1, @property.assessment_results.size
    result = @property.assessment_results.last
    assert_not_nil result.error_code
  end

  def runner_for_property(property)
    production_group = create(:assessment_production_group, property: property)
    Crawl::InteractionRunner.new(property, production_group)
  end
end
