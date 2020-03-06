# frozen_string_literal: true

require "uri"

# Implements a remote file attachement process for ActiveStorage within the context of an account
class Infrastructure::AttachRemoteUrl
  include Infrastructure::AttachmentContainerHelpers

  def initialize(account, user)
    @account = account
    @user = user
  end

  def attach(container_class, container_id, url)
    resource = attachment_container(container_class, container_id)
    uri = URI.parse(url)
    file = URI.open(url)

    resource.files.attach(io: file, filename: File.basename(uri.path))

    attachment = resource.files_attachments.order("created_at DESC").first
    [attachment, nil]
  end
end
