# frozen_string_literal: true

class Types::Assessment::IssueChangeEventType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :action, String, null: true
  field :action_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :issue, Types::Assessment::IssueType, null: false
  field :property, Types::Identity::PropertyType, null: false
  field :production_group, Types::Assessment::ProductionGroupType, null: true

  def production_group
    AssociationLoader.for(Assessment::IssueChangeEvent, :production_group).load(object)
  end

  def issue
    AssociationLoader.for(Assessment::IssueChangeEvent, :issue).load(object)
  end

  def property
    AssociationLoader.for(Assessment::IssueChangeEvent, :property).load(object)
  end
end
