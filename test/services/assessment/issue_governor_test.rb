# frozen_string_literal: true
require "test_helper"

module Assessment
  class IssueGovernorTest < ActiveSupport::TestCase
    setup do
      @property = create(:property)
      @governor = Assessment::IssueGovernor.new(@property, "governor-test")
    end

    test "it can create assessments" do
      assert_difference "@property.assessment_results.size", 1 do
        assert_difference "@property.issues.size", 0 do
          @governor.make_assessment("key-1", "home") do |assessment|
            assessment.score = 100
            assessment.score_mode = "binary"
          end
        end
      end
    end

    test "it produces issues for new assessments below the score threshold" do
      assert_difference "@property.assessment_results.size", 1 do
        assert_difference "@property.issues.size", 1 do
          assessment = @governor.make_assessment("key-1", "home") do |record|
            record.score = 50
            record.score_mode = "binary"
          end

          assert issue = assessment.issue
          assert_nil issue.closed_at
          assert_not_nil issue.opened_at
          assert_equal "home", issue.key_category
        end
      end
    end

    test "it doesn't produce issues for new assessments that currently have an open issue" do
      # create initial assessment and issue
      first_assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      issue = first_assessment.issue

      assert_difference "@property.issues.size", 0 do
        second_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 40
          record.score_mode = "binary"
        end

        assert_not_nil second_assessment.issue
        assert_equal issue, second_assessment.issue
      end

      assert_difference "@property.issues.size", 0 do
        third_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 60
          record.score_mode = "binary"
        end

        assert_not_nil third_assessment.issue
        assert_equal issue, third_assessment.issue
      end
    end

    test "it produces new issues for new assessments that currently have a closed issue" do
      assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end

      issue = assessment.issue
      issue.closed_at = Time.now.utc
      issue.save!

      assert_difference "@property.issues.size", 1 do
        new_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 50
          record.score_mode = "binary"
        end

        assert_not_nil new_assessment.issue
        assert_not_equal issue, new_assessment.issue
      end
    end

    test "it bumps issues' last seen at when more failing assessments arrive" do
      assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      issue = assessment.issue
      old_last_seen_at = issue.last_seen_at

      Timecop.travel(Time.now.utc + 10.minutes)
      new_assessment = nil
      assert_difference "@property.issues.size", 0 do
        new_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 50
          record.score_mode = "binary"
        end
      end

      assert_not_nil new_assessment.issue
      assert_equal issue, new_assessment.issue
      issue.reload
      assert_operator old_last_seen_at, :<, issue.last_seen_at
    end

    test "it closes issues when passing assessments arrive after failing ones" do
      assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      issue = assessment.issue

      new_assessment = nil
      assert_difference "@property.issues.size", 0 do
        new_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 100
          record.score_mode = "binary"
        end
      end

      assert_not_nil new_assessment.issue
      assert_equal issue, new_assessment.issue
      issue.reload
      assert_not_nil issue.closed_at
    end
  end
end
