# frozen_string_literal: true
require "test_helper"

class Infrastructure::AssessmentInfrastructureTest < ActiveJob::TestCase
  setup do
    create(:ambient_homesick_property)
  end

  test "it runs all the assessments for the shop" do
    assert_difference "Assessment::Result.count", 798 do
      with_synchronous_jobs do
        CrawlTest::PeriodicExecuteAssessmentsJob.run
      end
    end
  end
end
