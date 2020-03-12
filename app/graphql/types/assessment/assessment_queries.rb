# frozen_string_literal: true
module Types::Assessment
  module AssessmentQueries
    extend ActiveSupport::Concern

    included do
      field :issues, IssueType.connection_type, null: false, description: "Get all the issues for the current account"
      field :issue, IssueType, null: true do
        argument :number, GraphQL::Types::Int, required: true
      end
    end

    def issue(number:)
      context[:current_account].issues.find_by(number: number)
    end
  end
end
