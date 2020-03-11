# frozen_string_literal: true

module Assessment
  # Assessment manager that produces issues and manages their lifecycle as assessments are made
  class IssueGovernor
    SCORE_THRESHOLD = 90

    def initialize(property, production_scope)
      @property = property
      @account = property.account
      @production_scope = production_scope
    end

    def make_assessment(key, key_category)
      assessment = @property.assessment_results.build(
        account_id: @property.account_id,
        production_scope: @production_scope,
        key: key,
        key_category: key_category,
        assessment_at: Time.now.utc,
      )
      yield assessment

      Assessment::Result.transaction do
        assessment.issue = issue_for_assessment(assessment)
        if assessment.issue
          update_issue_open_state(assessment, assessment.issue)
          assessment.issue.save!
        end
        assessment.save!
      end

      assessment
    end

    def issue_for_assessment(assessment)
      attrs = { account_id: @account.id, key: assessment.key, key_category: assessment.key_category, closed_at: nil }
      if (issue = @property.issues.where(attrs).first)
        issue
      elsif assessment.score < SCORE_THRESHOLD
        # Only create new issues for failing assessments
        issue = @property.issues.build(attrs)
        issue.opened_at = Time.now.utc
        issue
      end
    end

    def update_issue_open_state(assessment, issue)
      # Close open issues for passing assessments
      if assessment.score > SCORE_THRESHOLD
        issue.closed_at = Time.now.utc
      end
    end
  end
end
