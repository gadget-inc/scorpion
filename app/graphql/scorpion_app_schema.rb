# frozen_string_literal: true

class ScorpionAppSchema < GraphQL::Schema
  mutation(Types::AppMutationType)
  query(Types::AppQueryType)
  use GraphQL::Batch
  use GraphQL::Pagination::Connections
end
