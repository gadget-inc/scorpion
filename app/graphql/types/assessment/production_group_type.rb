# frozen_string_literal: true

class Types::Assessment::ProductionGroupType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :reason, String, null: false
  field :started_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :property, Types::Identity::PropertyType, null: false
  field :issue_change_events, Types::Assessment::IssueChangeEventType.connection_type, null: false
  field :assessment_results, Types::Assessment::ResultType.connection_type, null: false

  field :changed_issue_count, Int, null: false

  def property
    AssociationLoader.for(Assessment::ProductionGroup, :property).load(object)
  end

  def issue_change_events
    AssociationLoader.for(Assessment::ProductionGroup, :issue_change_events).load(object)
  end

  def assessment_results
    AssociationLoader.for(Assessment::ProductionGroup, :assessment_results).load(object)
  end

  def changed_issue_count
    object.issue_change_events.count
  end
end
