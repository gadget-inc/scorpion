# frozen_string_literal: true

class ScorpionAuthSchema < GraphQL::Schema
  mutation(Types::AuthMutationType)
  query(Types::AuthQueryType)
  use GraphQL::Batch
end
