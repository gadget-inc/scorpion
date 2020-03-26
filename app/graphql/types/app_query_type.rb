# frozen_string_literal: true

module Types
  class AppQueryType < Types::BaseObject
    include Identity::IdentityQueries
    include Assessment::AssessmentQueries
    include Activity::ActivityQueries
  end
end
