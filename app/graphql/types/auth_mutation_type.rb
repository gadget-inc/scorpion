# frozen_string_literal: true

class Types::AuthMutationType < Types::BaseObject
  field :discard_account, mutation: Mutations::Identity::DiscardAccount
end
