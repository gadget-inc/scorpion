# frozen_string_literal: true

class Types::AppMutationType < Types::BaseObject
  # Identity
  field :invite_user, mutation: Mutations::Identity::InviteUser
  field :update_account, mutation: Mutations::Identity::UpdateAccount

  # Infrastructure
  field :attach_direct_uploaded_file, mutation: Mutations::Infrastructure::AttachDirectUploadedFile
  field :attach_remote_url, mutation: Mutations::Infrastructure::AttachRemoteUrl
end
