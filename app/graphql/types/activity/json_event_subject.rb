# frozen_string_literal: true

class Types::Activity::JSONEventSubject < Types::BaseObject
  field :json, Types::JSONScalar, null: false
  field :class_name, String, null: false

  def json
    object.as_json
  end

  def class_name
    object.class.name
  end
end
