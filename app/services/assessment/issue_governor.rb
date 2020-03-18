# frozen_string_literal: true

module Assessment
  # Assessment manager that produces issues and manages their lifecycle as assessments are made
  class IssueGovernor
    SCORE_THRESHOLD = 90

    def initialize(property, production_scope, cache_issues: true)
      @property = property
      @account = property.account
      @production_scope = production_scope
      @cache_issues = cache_issues
    end

    def make_assessment(key, key_category, subject_type = nil, subject_id = nil)
      assessment = @property.assessment_results.build(
        account_id: @property.account_id,
        production_scope: @production_scope,
        key: key,
        key_category: key_category,
        subject_type: subject_type,
        subject_id: subject_id,
        assessment_at: Time.now.utc,
      )
      yield assessment

      Assessment::Result.transaction do
        issue = issue_for_assessment(assessment)
        if issue
          assessment.issue = issue
          update_issue_state(issue, assessment)
        end
        assessment.save!
      end

      assessment
    end

    def issue_for_assessment(assessment)
      attrs = {
        account_id: @account.id,
        property_id: @property.id,
        key: assessment.key,
        key_category: assessment.key_category,
        subject_type: assessment.subject_type,
        subject_id: assessment.subject_id,
        closed_at: nil,
      }

      if (issue = existing_issue_for_attrs(attrs))
        issue
      elsif assessment.score < SCORE_THRESHOLD
        # Only create new issues for failing assessments
        issue = @property.issues.build(attrs)
        now = Time.now.utc
        issue.production_scope = @production_scope
        issue.opened_at = now
        issue.last_seen_at = now
        issue
      end
    end

    def reload_cache!
      if @cache_issues
        @issue_cache = nil
        issue_cache
      end
    end

    private

    def existing_issue_for_attrs(attrs)
      if @cache_issues
        if (key_group = issue_cache[attrs[:key]])
          key_group.detect do |existing|
            existing.key_category == attrs[:key_category] &&
            existing.subject_type == attrs[:subject_type] &&
            existing.subject_id == attrs[:subject_id]
          end
        end
      else
        @property.issues.where(attrs).first
      end
    end

    def issue_cache
      @issue_cache ||= @property.issues.where(account_id: @account.id, production_scope: @production_scope, closed_at: nil).group_by(&:key)
    end

    def update_issue_state(issue, new_assessment)
      # Close open issues for passing assessments
      if new_assessment.score > SCORE_THRESHOLD
        issue.closed_at = Time.now.utc
      else
        issue.last_seen_at = Time.now.utc
      end

      if @cache_issues
        issue_cache[issue.key] ||= []
        if issue.closed_at.nil?
          issue_cache[issue.key] << issue unless issue_cache[issue.key].include?(issue)
        else
          issue_cache[issue.key].delete(issue)
        end
      end

      issue.save!
    end
  end
end
