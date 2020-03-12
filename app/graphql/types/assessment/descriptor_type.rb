# frozen_string_literal: true

class Types::Assessment::DescriptorType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :key, String, null: false
  field :title, String, null: false
  field :description, String, null: false

  def id
    key
  end

  def description
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    markdown.render(object.description)
  end
end
