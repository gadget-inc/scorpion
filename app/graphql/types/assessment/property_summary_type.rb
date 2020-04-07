# frozen_string_literal: true

class Types::Assessment::PropertySummaryType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :property, Types::Identity::PropertyType, null: false

  field :open_issue_count, Integer, null: false
  field :open_urgent_issue_count, Integer, null: false
  field :open_warning_issue_count, Integer, null: false
  field :current_status, String, null: false
  field :most_urgent_issues, [Types::Assessment::IssueType], null: false

  def id
    object.property.id
  end
end
