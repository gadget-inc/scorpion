# frozen_string_literal: true

# Aggregate object describing a bunch of different pieces of property / assessment state
class Assessment::PropertySummary
  extend Memoist

  attr_reader :property

  def initialize(property)
    @property = property
  end

  def most_urgent_issues
    @property.issues.open.order_by_severity.limit(5)
  end

  def open_issue_count
    @property.issues.open.count
  end

  def open_urgent_issue_count
    @property.issues.open.severity("urgent").count
  end

  def open_warning_issue_count
    @property.issues.open.severity("warning").count
  end

  def current_status
    if open_urgent_issue_count > 0
      "critical"
    elsif open_warning_issue_count > 0
      "warning"
    else
      "success"
    end
  end

  memoize :most_urgent_issues
  memoize :open_issue_count
  memoize :open_urgent_issue_count
  memoize :open_warning_issue_count
  memoize :current_status
end
