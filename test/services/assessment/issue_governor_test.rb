# frozen_string_literal: true
require "test_helper"

module Assessment
  class IssueGovernorTest < ActiveSupport::TestCase
    setup do
      @property = create(:property)
      @production_group = create(:assessment_production_group, property: @property)
      @governor = Assessment::IssueGovernor.new(@property, @production_group, "governor-test")
      @descriptor = Assessment::Descriptor.create!(key: "key-1", title: "Test", description: "Test", severity: "low")
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

          assert_equal 1, issue.issue_change_events.size
          assert event = issue.issue_change_events.first
          assert_equal "open", event.action
          assert_equal @production_group, event.production_group
        end
      end
    end

    test "it doesn't produce new issues for new assessments that currently have an open issue" do
      # create initial assessment and issue
      first_assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      issue = first_assessment.issue
      number = issue.number

      assert_difference "@property.issues.size", 0 do
        second_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 40
          record.score_mode = "binary"
        end

        assert_not_nil second_assessment.issue
        assert_equal issue, second_assessment.issue
        issue.reload
        assert_equal 1, issue.issue_change_events.size
      end

      assert_difference "@property.issues.size", 0 do
        third_assessment = @governor.make_assessment("key-1", "home") do |record|
          record.score = 60
          record.score_mode = "binary"
        end

        assert_not_nil third_assessment.issue
        assert_equal issue, third_assessment.issue
        assert_equal number, issue.reload.number
        issue.reload
        assert_equal 1, issue.issue_change_events.size
      end
    end

    test "it doesn't produce issues for new assessments with subjects that currently have an open issue" do
      # create initial assessment and issue
      first_assessment = @governor.make_assessment("key-1", "home", "product", "1") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      issue = first_assessment.issue

      assert_difference "@property.issues.size", 0 do
        second_assessment = @governor.make_assessment("key-1", "home", "product", "1") do |record|
          record.score = 40
          record.score_mode = "binary"
        end

        assert_not_nil second_assessment.issue
        assert_equal issue, second_assessment.issue
        issue.reload
        assert_equal 1, issue.issue_change_events.size
      end

      assert_difference "@property.issues.size", 0 do
        third_assessment = @governor.make_assessment("key-1", "home", "product", "1") do |record|
          record.score = 60
          record.score_mode = "binary"
        end

        assert_not_nil third_assessment.issue
        assert_equal issue, third_assessment.issue
        issue.reload
        assert_equal 1, issue.issue_change_events.size
      end
    end

    test "it produces new issues for new assessments that currently have a closed issue" do
      # Open and close a first issue
      assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end

      @first_issue = assessment.issue
      assert_nil @first_issue.closed_at

      @governor.make_assessment("key-1", "home") do |record|
        record.score = 100
        record.score_mode = "binary"
      end

      @first_issue.reload
      assert_not_nil @first_issue.closed_at

      # Then make a new assessment of the same nature, ensuring a new issue is opened
      assert_difference "@property.issues.size", 1 do
        assert_difference "@first_issue.issue_change_events.size", 0 do
          new_assessment = @governor.make_assessment("key-1", "home") do |record|
            record.score = 50
            record.score_mode = "binary"
          end

          assert_not_nil new_assessment.issue
          assert_not_equal @first_issue, new_assessment.issue
          assert_operator @first_issue.number, :<, new_assessment.issue.number
          assert_equal 1, new_assessment.issue.issue_change_events.size
        end
      end
    end

    test "it bumps issues' last seen at when more failing assessments arrive" do
      assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      @issue = assessment.issue
      old_last_seen_at = @issue.last_seen_at

      Timecop.travel(Time.now.utc + 10.minutes)
      new_assessment = nil
      assert_difference "@property.issues.size", 0 do
        assert_difference "@issue.issue_change_events.size", 0 do
          new_assessment = @governor.make_assessment("key-1", "home") do |record|
            record.score = 50
            record.score_mode = "binary"
          end
        end
      end

      assert_not_nil new_assessment.issue
      assert_equal @issue, new_assessment.issue
      @issue.reload
      assert_operator old_last_seen_at, :<, @issue.last_seen_at
    end

    test "it closes issues when passing assessments arrive after failing ones" do
      assessment = @governor.make_assessment("key-1", "home") do |record|
        record.score = 50
        record.score_mode = "binary"
      end
      issue = assessment.issue

      new_assessment = nil
      assert_difference "@property.issues.size", 0 do
        assert_difference "@property.issue_change_events.size", 1 do
          new_assessment = @governor.make_assessment("key-1", "home") do |record|
            record.score = 100
            record.score_mode = "binary"
          end
        end
      end

      assert_not_nil new_assessment.issue
      assert_equal issue, new_assessment.issue
      issue.reload
      assert_not_nil issue.closed_at
    end

    test "it produces different issues for assessments with different subjects" do
      first_assessment = nil
      first_issue = nil

      assert_difference "@property.assessment_results.size", 1 do
        assert_difference "@property.issues.size", 1 do
          first_assessment = @governor.make_assessment("key-1", "home", "product", "1") do |record|
            record.score = 50
            record.score_mode = "binary"
          end

          assert first_issue = first_assessment.issue
          assert_nil first_issue.closed_at
          assert_equal "product", first_issue.subject_type
          assert_equal "1", first_issue.subject_id
          assert_equal 1, first_issue.issue_change_events.size
        end
      end

      assert_difference "@property.assessment_results.size", 1 do
        assert_difference "@property.issues.size", 1 do
          second_assessment = @governor.make_assessment("key-1", "home", "product", "2") do |record|
            record.score = 50
            record.score_mode = "binary"
          end

          first_issue.reload

          assert second_issue = second_assessment.issue
          assert_not_equal first_issue, second_issue
          assert_nil first_issue.reload.closed_at
          assert_nil second_issue.closed_at
          assert_equal "product", second_issue.subject_type
          assert_equal "2", second_issue.subject_id
          assert_operator first_issue.number, :<, second_issue.number

          assert_equal 1, first_issue.issue_change_events.size
          assert_equal 1, second_issue.issue_change_events.size
          assert_not_equal first_issue.issue_change_events.first, second_issue.issue_change_events.first
        end
      end
    end

    test "fixing an issue for one subject doesn't fix it for another subject" do
      first_assessment = @governor.make_assessment("key-1", "home", "product", "1") do |record|
        record.score = 50
        record.score_mode = "binary"
      end

      assert first_issue = first_assessment.issue
      second_assessment = @governor.make_assessment("key-1", "home", "product", "2") do |record|
        record.score = 50
        record.score_mode = "binary"
      end

      assert second_issue = second_assessment.issue
      assert_not_equal first_issue, second_issue

      assert_difference "@property.issues.size", 0 do
        @governor.make_assessment("key-1", "home", "product", "2") do |record|
          record.score = 100
          record.score_mode = "binary"
        end
      end

      first_issue.reload
      second_issue.reload

      assert_nil first_issue.closed_at
      assert_not_nil second_issue.closed_at
    end
  end
end
